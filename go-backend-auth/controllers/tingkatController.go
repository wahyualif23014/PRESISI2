package controllers

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

func GetTingkat(c *gin.Context) {
	var rawData []models.KesatuanDetail

	// --- QUERY PERBAIKAN ---
	// Masalah: Error 1054 Unknown column 't.deletestatus'
	// Solusi: Hapus 'WHERE t.deletestatus != 1'
	query := `
		SELECT 
			t.kode AS kode,
			t.nama AS nama_satuan,
			COALESCE(j.namajabatan, '-') AS jabatan,
			COALESCE(a.nama, 'Belum Ada Pejabat') AS nama_pejabat,
			COALESCE(a.hp, '-') AS no_hp
		FROM tingkat t
		-- Join ke Anggota (Filter deletestatus HANYA untuk tabel anggota 'a', bukan tingkat 't')
		LEFT JOIN anggota a ON a.idtugas = t.kode AND a.deletestatus != '1'
		LEFT JOIN jabatan j ON a.idjabatan = j.idjabatan
		-- GROUP BY
		GROUP BY t.kode, t.nama, j.namajabatan, a.nama, a.hp
		ORDER BY t.kode ASC
	`

	if err := initializers.DB.Raw(query).Scan(&rawData).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database Error: " + err.Error()})
		return
	}

	// --- LOGIC HIERARKI (Sama seperti sebelumnya) ---
	var polresList []models.KesatuanDetail
	var anakMap = make(map[string][]models.KesatuanDetail)

	for i := range rawData {
		kode := rawData[i].Kode
		nama := rawData[i].NamaSatuan

		// 1. Logic Wilayah (Bersihkan Nama)
		cleanName := nama
		cleanName = strings.Replace(cleanName, "POLSEK ", "", 1)
		cleanName = strings.Replace(cleanName, "POLRES ", "", 1)
		cleanName = strings.Replace(cleanName, "POLRESTA ", "", 1)
		cleanName = strings.Replace(cleanName, "POLRESTABES ", "", 1)
		cleanName = strings.Replace(cleanName, "POLDA ", "", 1)
		rawData[i].Wilayah = cleanName

		// 2. Logic Induk & Anak (Berdasarkan Panjang Kode)
		if len(kode) > 5 {
			// Anak (Polsek) -> Kode Induk = 5 digit pertama
			indukID := kode[:5]
			rawData[i].KodeInduk = indukID
			anakMap[indukID] = append(anakMap[indukID], rawData[i])
		} else {
			// Induk (Polres)
			rawData[i].KodeInduk = ""
		}
	}

	// 3. Gabungkan Anak ke Induk
	for _, item := range rawData {
		if len(item.Kode) <= 5 {
			if anak, ada := anakMap[item.Kode]; ada {
				item.DaftarPolsek = anak
				item.TotalPolsek = len(anak)
			}
			polresList = append(polresList, item)
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Data Struktur Komando Berhasil Dimuat",
		"total_data": len(polresList),
		"data":       polresList,
	})
}
