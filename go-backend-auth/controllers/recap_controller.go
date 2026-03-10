package controllers

import (
	"fmt"
	"net/http"
	"sort"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/xuri/excelize/v2"
)

type RecapResponse struct {
	ID           string  `json:"id"`
	NamaWilayah  string  `json:"nama_wilayah"`
	PotensiLahan float64 `json:"potensi_lahan"`
	TanamLahan   float64 `json:"tanam_lahan"`
	PanenLuas    float64 `json:"panen_luas"`
	PanenTon     float64 `json:"panen_ton"`
	Serapan      float64 `json:"serapan"`
	Level        string  `json:"level"`
	NamaPolsek   string  `json:"nama_polsek,omitempty"`
}

// --- GET DATA UNTUK UI (HIERARKI) ---
func GetRecapData(c *gin.Context) {
	query := `
		SELECT 
			w.kode as id,
			w.nama as nama_wilayah,
			COALESCE(SUM(l.luaslahan), 0) as potensi_lahan,
			COALESCE(SUM(t.luastanam), 0) as tanam_lahan,
			COALESCE(SUM(p.luaspanen), 0) as panen_luas,
			COALESCE(SUM(p.totalpanen), 0) as panen_ton,
			COALESCE(SUM(d.totaldistribusi), 0) as serapan,
			'desa' as level,
			COALESCE(pk.nama, '-') as nama_polsek
		FROM wilayah w
		LEFT JOIN lahan l ON l.idwilayah = w.kode
		LEFT JOIN tanam t ON t.idlahan = l.idlahan
		LEFT JOIN panen p ON p.idlahan = l.idlahan
		LEFT JOIN distribusi d ON d.idlahan = l.idlahan
		LEFT JOIN wilayah pk ON pk.kode = SUBSTR(w.kode, 1, 8)
		WHERE CHAR_LENGTH(w.kode) > 8
		GROUP BY w.kode, w.nama, pk.nama
		ORDER BY w.kode ASC
	`
	rows, err := initializers.DB.Raw(query).Rows()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	polresMap := make(map[string]*RecapResponse)
	polsekMap := make(map[string]*RecapResponse)
	var desaList []RecapResponse

	for rows.Next() {
		var r RecapResponse
		rows.Scan(&r.ID, &r.NamaWilayah, &r.PotensiLahan, &r.TanamLahan, &r.PanenLuas, &r.PanenTon, &r.Serapan, &r.Level, &r.NamaPolsek)

		// Validasi ID agar tidak panic saat slicing
		if len(r.ID) < 8 {
			continue
		}

		pID, sID := r.ID[:5], r.ID[:8]

		// Agregasi Level Polres
		if _, ok := polresMap[pID]; !ok {
			var n string
			initializers.DB.Table("wilayah").Select("nama").Where("kode = ?", pID).Scan(&n)
			polresMap[pID] = &RecapResponse{
				ID:          pID,
				NamaWilayah: strings.TrimPrefix(n, "KAB. "),
				Level:       "polres",
			}
		}
		addSums(polresMap[pID], r)

		// Agregasi Level Polsek
		if _, ok := polsekMap[sID]; !ok {
			polsekMap[sID] = &RecapResponse{
				ID:          sID,
				NamaWilayah: r.NamaPolsek,
				Level:       "polsek",
			}
		}
		addSums(polsekMap[sID], r)

		desaList = append(desaList, r)
	}

	var finalData []RecapResponse

	// Menyusun data Hierarki (Flat List untuk Frontend)
	// Catatan: Iterasi Map di Go itu acak, jadi kita perlu sorting manual nanti
	for pID, pData := range polresMap {
		finalData = append(finalData, *pData)
		for sID, sData := range polsekMap {
			if strings.HasPrefix(sID, pID) {
				finalData = append(finalData, *sData)
				for _, dData := range desaList {
					if strings.HasPrefix(dData.ID, sID) {
						finalData = append(finalData, dData)
					}
				}
			}
		}
	}

	// PENTING: Sort data berdasarkan ID agar urutannya rapi (Polres -> Polsek -> Desa)
	// Karena map di Go iterasinya random, langkah ini wajib agar report tidak berantakan
	sort.Slice(finalData, func(i, j int) bool {
		return finalData[i].ID < finalData[j].ID
	})

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": finalData})
}

// --- FUNGSI EXPORT EXCEL ---
func ExportRecapExcel(c *gin.Context) {
	f := excelize.NewFile()
	defer func() {
		if err := f.Close(); err != nil {
			fmt.Println(err)
		}
	}()

	headerStyle, _ := f.NewStyle(&excelize.Style{
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"#F4CCCC"}, Pattern: 1},
		Font:      &excelize.Font{Bold: true, Color: "#000000", Size: 10},
		Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center", WrapText: true},
		Border: []excelize.Border{
			{Type: "left", Color: "000000", Style: 1},
			{Type: "top", Color: "000000", Style: 1},
			{Type: "bottom", Color: "000000", Style: 1},
			{Type: "right", Color: "000000", Style: 1},
		},
	})

	titleStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Size: 14},
		Alignment: &excelize.Alignment{Horizontal: "center", Vertical: "center"},
	})

	borderStyle, _ := f.NewStyle(&excelize.Style{
		Border: []excelize.Border{
			{Type: "left", Color: "000000", Style: 1},
			{Type: "top", Color: "000000", Style: 1},
			{Type: "bottom", Color: "000000", Style: 1},
			{Type: "right", Color: "000000", Style: 1},
		},
	})

	queryUtama := `
		SELECT 
			d.kode as kode_desa, d.nama as nama_desa,
			COALESCE(s.kode, '') as kode_polsek, COALESCE(s.nama, '-') as nama_polsek,
			COALESCE(r.kode, '') as kode_polres, COALESCE(r.nama, '-') as nama_polres,
			COALESCE(SUM(l.luaslahan), 0) as potensi,
			COALESCE(SUM(t.luastanam), 0) as tanam,
			COALESCE(SUM(p.luaspanen), 0) as panen_luas,
			COALESCE(SUM(p.totalpanen), 0) as panen_ton,
			COALESCE(SUM(dis.totaldistribusi), 0) as serapan
		FROM wilayah d
		LEFT JOIN wilayah s ON s.kode = SUBSTR(d.kode, 1, 8)
		LEFT JOIN wilayah r ON r.kode = SUBSTR(d.kode, 1, 5)
		LEFT JOIN lahan l ON l.idwilayah = d.kode
		LEFT JOIN tanam t ON t.idlahan = l.idlahan
		LEFT JOIN panen p ON p.idlahan = l.idlahan
		LEFT JOIN distribusi dis ON dis.idlahan = l.idlahan
		WHERE CHAR_LENGTH(d.kode) > 8
		GROUP BY d.kode, d.nama, s.kode, s.nama, r.kode, r.nama
		ORDER BY r.kode ASC, s.kode ASC, d.kode ASC
	`
	rows, err := initializers.DB.Raw(queryUtama).Rows()
	if err != nil {
		fmt.Println("ERROR QUERY 1:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data database"})
		return
	}
	defer rows.Close()

	type PolsekRekap struct {
		NamaPolres string
		NamaPolsek string
		Potensi    float64
		Tanam      float64
		PanenLuas  float64
		PanenTon   float64
		Serapan    float64
	}
	var listPolsek []PolsekRekap
	var currentPolsekData *PolsekRekap

	sheet1 := "Rekap per Wilayah"
	f.SetSheetName("Sheet1", sheet1)

	f.SetCellValue(sheet1, "A1", "REKAPITULASI DATA PRODUKSI LAHAN")
	f.MergeCell(sheet1, "A1", "I1")
	f.SetCellStyle(sheet1, "A1", "A1", titleStyle)

	headers1 := []string{"No.", "Polsek", "Polres", "Wilayah", "Potensi Lahan (Ha)", "Tanam Lahan (Ha)", "Luas Panen (Ha)", "Total Panen (Ton)", "Total Serapan (Ton)"}
	for i, h := range headers1 {
		colName, _ := excelize.CoordinatesToCellName(i+1, 2)
		f.SetCellValue(sheet1, colName, h)
	}
	f.SetRowStyle(sheet1, 2, 2, headerStyle)
	f.SetColWidth(sheet1, "B", "D", 25)

	rowIdx1 := 3
	no1 := 1
	startMergeRow := 3
	lastPolsek := ""

	for rows.Next() {
		var kodeDesa, namaDesa, kodePolsek, namaPolsek, kodePolres, namaPolres string
		var potensi, tanam, panenLuas, panenTon, serapan float64

		rows.Scan(&kodeDesa, &namaDesa, &kodePolsek, &namaPolsek, &kodePolres, &namaPolres, &potensi, &tanam, &panenLuas, &panenTon, &serapan)

		namaPolres = strings.TrimPrefix(namaPolres, "KAB. ")
		if !strings.HasPrefix(namaPolres, "POLRES") {
			namaPolres = "POLRES " + namaPolres
		}

		if namaPolsek != lastPolsek {
			if lastPolsek != "" && rowIdx1 > startMergeRow {
				cellStartB, _ := excelize.CoordinatesToCellName(2, startMergeRow)
				cellEndB, _ := excelize.CoordinatesToCellName(2, rowIdx1-1)
				cellStartC, _ := excelize.CoordinatesToCellName(3, startMergeRow)
				cellEndC, _ := excelize.CoordinatesToCellName(3, rowIdx1-1)
				f.MergeCell(sheet1, cellStartB, cellEndB)
				f.MergeCell(sheet1, cellStartC, cellEndC)
			}
			lastPolsek = namaPolsek
			startMergeRow = rowIdx1

			if currentPolsekData != nil {
				listPolsek = append(listPolsek, *currentPolsekData)
			}
			currentPolsekData = &PolsekRekap{NamaPolres: namaPolres, NamaPolsek: namaPolsek}
		}

		currentPolsekData.Potensi += potensi
		currentPolsekData.Tanam += tanam
		currentPolsekData.PanenLuas += panenLuas
		currentPolsekData.PanenTon += panenTon
		currentPolsekData.Serapan += serapan

		f.SetCellValue(sheet1, fmt.Sprintf("A%d", rowIdx1), no1)
		f.SetCellValue(sheet1, fmt.Sprintf("B%d", rowIdx1), namaPolsek)
		f.SetCellValue(sheet1, fmt.Sprintf("C%d", rowIdx1), namaPolres)
		f.SetCellValue(sheet1, fmt.Sprintf("D%d", rowIdx1), namaDesa)
		f.SetCellValue(sheet1, fmt.Sprintf("E%d", rowIdx1), potensi)
		f.SetCellValue(sheet1, fmt.Sprintf("F%d", rowIdx1), tanam)
		f.SetCellValue(sheet1, fmt.Sprintf("G%d", rowIdx1), panenLuas)
		f.SetCellValue(sheet1, fmt.Sprintf("H%d", rowIdx1), panenTon)
		f.SetCellValue(sheet1, fmt.Sprintf("I%d", rowIdx1), serapan)

		cellStartRow, _ := excelize.CoordinatesToCellName(1, rowIdx1)
		cellEndRow, _ := excelize.CoordinatesToCellName(9, rowIdx1)
		f.SetCellStyle(sheet1, cellStartRow, cellEndRow, borderStyle)

		rowIdx1++
		no1++
	}

	if rowIdx1 > startMergeRow {
		cellStartB, _ := excelize.CoordinatesToCellName(2, startMergeRow)
		cellEndB, _ := excelize.CoordinatesToCellName(2, rowIdx1-1)
		cellStartC, _ := excelize.CoordinatesToCellName(3, startMergeRow)
		cellEndC, _ := excelize.CoordinatesToCellName(3, rowIdx1-1)
		f.MergeCell(sheet1, cellStartB, cellEndB)
		f.MergeCell(sheet1, cellStartC, cellEndC)
	}
	if currentPolsekData != nil {
		listPolsek = append(listPolsek, *currentPolsekData)
	}

	sheet2 := "Rekap Per Polsek"
	f.NewSheet(sheet2)

	f.SetCellValue(sheet2, "A1", "REKAPITULASI DATA PRODUKSI LAHAN")
	f.MergeCell(sheet2, "A1", "H1")
	f.SetCellStyle(sheet2, "A1", "A1", titleStyle)

	headers2 := []string{"No.", "Polsek", "Polres", "Potensi Lahan (Ha)", "Tanam Lahan (Ha)", "Luas Panen (Ha)", "Total Panen (Ton)", "Total Serapan (Ton)"}
	for i, h := range headers2 {
		colName, _ := excelize.CoordinatesToCellName(i+1, 2)
		f.SetCellValue(sheet2, colName, h)
	}
	f.SetRowStyle(sheet2, 2, 2, headerStyle)
	f.SetColWidth(sheet2, "B", "C", 25)

	rowIdx2 := 3
	for i, polsek := range listPolsek {
		f.SetCellValue(sheet2, fmt.Sprintf("A%d", rowIdx2), i+1)
		f.SetCellValue(sheet2, fmt.Sprintf("B%d", rowIdx2), polsek.NamaPolsek)
		f.SetCellValue(sheet2, fmt.Sprintf("C%d", rowIdx2), polsek.NamaPolres)
		f.SetCellValue(sheet2, fmt.Sprintf("D%d", rowIdx2), polsek.Potensi)
		f.SetCellValue(sheet2, fmt.Sprintf("E%d", rowIdx2), polsek.Tanam)
		f.SetCellValue(sheet2, fmt.Sprintf("F%d", rowIdx2), polsek.PanenLuas)
		f.SetCellValue(sheet2, fmt.Sprintf("G%d", rowIdx2), polsek.PanenTon)
		f.SetCellValue(sheet2, fmt.Sprintf("H%d", rowIdx2), polsek.Serapan)

		cellStartRow, _ := excelize.CoordinatesToCellName(1, rowIdx2)
		cellEndRow, _ := excelize.CoordinatesToCellName(8, rowIdx2)
		f.SetCellStyle(sheet2, cellStartRow, cellEndRow, borderStyle)
		rowIdx2++
	}

	sheet3 := "Perincian Data"
	f.NewSheet(sheet3)

	f.SetCellValue(sheet3, "A1", "PERINCIAN DATA PRODUKSI LAHAN")
	f.MergeCell(sheet3, "A1", "AN1")
	f.SetCellStyle(sheet3, "A1", "A1", titleStyle)

	groups := []struct {
		Nama  string
		Start string
		End   string
	}{
		{"Wilayah", "D2", "H2"},
		{"Polisi Penggerak", "I2", "J2"},
		{"Penanggung Jawab", "K2", "M2"},
		{"Data Potensi Lahan", "N2", "Y2"},
		{"Tanam Lahan", "Z2", "AE2"},
		{"Panen", "AF2", "AJ2"},
		{"Serapan", "AK2", "AN2"},
	}
	for _, g := range groups {
		f.SetCellValue(sheet3, g.Start, g.Nama)
		f.MergeCell(sheet3, g.Start, g.End)
	}

	headers3 := []string{
		"Polres", "Polsek", "Alamat", "Kabupaten", "Kecamatan", "Kelurahan", "Latitude", "Longitude",
		"Nama", "No. HP",
		"Nama", "No. HP", "Ket. PJ",
		"Jenis Lahan", "Komoditi", "Status Lahan", "Jml. Poktan", "Luas Lahan (Ha)", "Jml. Petani", "Nama Lembaga", "Sumber Data", "No. SK", "Nama Pesantren", "Jml. Santri", "Keterangan Lahan",
		"Tgl. Tanam", "Jenis Bibit", "Kebutuhan Bibit", "Luas Tanam (Ha)", "Estimasi Panen", "Keterangan",
		"Tgl. Panen", "Jenis Panen", "Luas Panen (Ha)", "Hasil Panen (Ton)", "Keterangan",
		"Tgl. Serapan", "Tujuan Serapan", "Total Serapan (Ton)", "Keterangan",
	}

	for i, h := range headers3 {
		colName, _ := excelize.CoordinatesToCellName(i+1, 3)
		f.SetCellValue(sheet3, colName, h)
		if i < 3 {
			colName2, _ := excelize.CoordinatesToCellName(i+1, 2)
			f.SetCellValue(sheet3, colName2, h)
			f.MergeCell(sheet3, colName2, colName)
		}
	}
	f.SetRowStyle(sheet3, 2, 3, headerStyle)

	queryDetail := `
		SELECT 
			COALESCE(r.nama, '-') as polres, COALESCE(s.nama, '-') as polsek,
			d.nama as alamat, r.nama as kabupaten, s.nama as kecamatan, d.nama as kelurahan,
			COALESCE(CAST(l.longi AS CHAR), '') as latitude,
			COALESCE(CAST(l.lat AS CHAR), '') as longitude,
			COALESCE(l.cp, '') as nama_polisi,
			COALESCE(l.hp, '') as hp_polisi,
			COALESCE(l.cppolisi, '') as nama_pj,
			COALESCE(l.hppolisi, '') as hp_pj,
			COALESCE(l.ketcp, '') as ket_pj,
			COALESCE(CAST(l.idjenislahan AS CHAR), '') as jenis_lahan,
			COALESCE(CONCAT(k.jeniskomoditi, ' - ', k.namakomoditi), '') as komoditi,
			CASE l.status
				WHEN 1 THEN 'Kosong'
				WHEN 2 THEN 'Tanam'
				WHEN 3 THEN 'Panen'
				WHEN 4 THEN 'Distribusi'
				ELSE '-'
			END as status_lahan,
			COALESCE(CAST(l.poktan AS CHAR), '0') as jml_poktan,
			COALESCE(l.luaslahan, 0) as luas_lahan,
			COALESCE(CAST(l.jmlsantri AS CHAR), '0') as jml_petani,
			COALESCE(l.lembaga, '') as nama_lembaga,
			COALESCE(l.sumberdata, '') as sumber_data,
			COALESCE(l.sk, '') as no_sk,
			COALESCE(l.keterangan, '') as ket_lahan,
			COALESCE(CAST(t.tgltanam AS CHAR), '') as tgl_tanam,
			COALESCE(t.bibitdigunakan, '') as jenis_bibit,
			COALESCE(CAST(t.kebutuhanbibit AS CHAR), '0') as kebutuhan_bibit,
			COALESCE(t.luastanam, 0) as luas_tanam,
			COALESCE(CONCAT(t.estawalpanen, ' s/d ', t.estakhirpanen), '') as estimasi_panen,
			COALESCE(t.keterangan, '') as ket_tanam,
			COALESCE(CAST(p.tglpanen AS CHAR), '') as tgl_panen,
			COALESCE(p.jenispanen, '') as jenis_panen,
			COALESCE(p.totalpanen, 0) as luas_panen,
			COALESCE(p.totalpanen, 0) as total_panen_ton,
			COALESCE(dis.totaldistribusi, 0) as serapan
		FROM wilayah d
		LEFT JOIN wilayah s ON s.kode = SUBSTR(d.kode, 1, 8)
		LEFT JOIN wilayah r ON r.kode = SUBSTR(d.kode, 1, 5)
		LEFT JOIN lahan l ON l.idwilayah = d.kode
		LEFT JOIN komoditi k ON k.idkomoditi = l.idkomoditi
		LEFT JOIN tanam t ON t.idlahan = l.idlahan
		LEFT JOIN panen p ON p.idlahan = l.idlahan
		LEFT JOIN distribusi dis ON dis.idlahan = l.idlahan
		WHERE CHAR_LENGTH(d.kode) > 8
		ORDER BY r.kode ASC, s.kode ASC, d.kode ASC
	`
	rowsDetail, errDetail := initializers.DB.Raw(queryDetail).Rows()
	if errDetail != nil {
		fmt.Println("ERROR QUERY SHEET 3:", errDetail) // Cek terminal Go jika Sheet 3 kosong
	} else {
		defer rowsDetail.Close()
		rowIdx3 := 4
		for rowsDetail.Next() {
			var (
				polres, polsek, alamat, kab, kec, kel              string
				latitude, longitude                                string
				namaPolisi, hpPolisi, namaPJ, hpPJ, ketPJ          string
				jenisLahan, komoditi, statusLahan, jmlPoktan       string
				luasLahan                                          float64
				jmlPetani, namaLembaga, sumberData, noSK, ketLahan string
				tglTanam, jenisBibit, kebutuhanBibit               string
				luasTanam                                          float64
				estimasiPanen, ketTanam                            string
				tglPanen, jenisPanen                               string
				luasPanen, totalPanenTon, serapan                  float64
			)

			rowsDetail.Scan(
				&polres, &polsek, &alamat, &kab, &kec, &kel,
				&latitude, &longitude, &namaPolisi, &hpPolisi, &namaPJ, &hpPJ, &ketPJ,
				&jenisLahan, &komoditi, &statusLahan, &jmlPoktan, &luasLahan, &jmlPetani, &namaLembaga, &sumberData, &noSK, &ketLahan,
				&tglTanam, &jenisBibit, &kebutuhanBibit, &luasTanam, &estimasiPanen, &ketTanam,
				&tglPanen, &jenisPanen, &luasPanen, &totalPanenTon, &serapan,
			)

			polres = strings.TrimPrefix(polres, "KAB. ")
			if !strings.HasPrefix(polres, "POLRES") {
				polres = "POLRES " + polres
			}

			dataRow := []interface{}{
				polres, polsek, alamat, kab, kec, kel, latitude, longitude,
				namaPolisi, hpPolisi,
				namaPJ, hpPJ, ketPJ,
				jenisLahan, komoditi, statusLahan, jmlPoktan, luasLahan, jmlPetani, namaLembaga, sumberData, noSK, "", "", ketLahan,
				tglTanam, jenisBibit, kebutuhanBibit, luasTanam, estimasiPanen, ketTanam,
				tglPanen, jenisPanen, luasPanen, totalPanenTon, "",
				"", "", serapan, "",
			}

			for colNum, value := range dataRow {
				cellName, _ := excelize.CoordinatesToCellName(colNum+1, rowIdx3)
				f.SetCellValue(sheet3, cellName, value)
			}

			cellStartRow, _ := excelize.CoordinatesToCellName(1, rowIdx3)
			cellEndRow, _ := excelize.CoordinatesToCellName(40, rowIdx3)
			f.SetCellStyle(sheet3, cellStartRow, cellEndRow, borderStyle)

			rowIdx3++
		}
	}

	fileName := fmt.Sprintf("Rekap_Presisi_%s.xlsx", time.Now().Format("20060102_150405"))

	c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s", fileName))
	c.Header("Content-Transfer-Encoding", "binary")
	c.Header("Cache-Control", "no-cache")

	if err := f.Write(c.Writer); err != nil {
		fmt.Println("Error writing excel file:", err)
	}
}

// --- HELPER FUNCTION (Wajib Ada) ---
func addSums(t *RecapResponse, s RecapResponse) {
	t.PotensiLahan += s.PotensiLahan
	t.TanamLahan += s.TanamLahan
	t.PanenLuas += s.PanenLuas
	t.PanenTon += s.PanenTon
	t.Serapan += s.Serapan
}
