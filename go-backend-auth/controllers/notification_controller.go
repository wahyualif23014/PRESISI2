package controllers

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/models" // Sesuaikan dengan path project Anda
	"gorm.io/gorm"
)

type NotificationController struct {
	DB *gorm.DB
}

// NewNotificationController inisialisasi controller
func NewNotificationController(db *gorm.DB) *NotificationController {
	return &NotificationController{DB: db}
}

// 1. Ambil Daftar Notifikasi
func (nc *NotificationController) GetMyNotifications(c *gin.Context) {
	// --- SAYA KOMENTAR SEMENTARA AGAR TIDAK ERROR "UNUSED VARIABLE" ---
	// adminIdTugas, exists := c.Get("id_tugas")
	// if !exists {
	// 	adminIdTugas = ""
	// }

	var results []models.NotificationQueryResult

	// Query langsung ke tabel lahan JOIN anggota
	err := nc.DB.Table("lahan l").
		Select("l.idlahan, a.nama as nama_operator, l.alamat as lokasi_lahan, l.luaslahan, l.datetransaction, l.statuslahan, l.tglvalid").
		Joins("LEFT JOIN anggota a ON l.idanggota = a.idanggota").
		Where("l.statuslahan IN ?", []string{"1", "2"}).
		// Where("l.idtingkat LIKE ?", fmt.Sprintf("%v%%", adminIdTugas)). // <-- Filter dimatikan sementara
		Order("IFNULL(l.tglvalid, l.datetransaction) DESC").
		Limit(20).
		Scan(&results).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data notifikasi"})
		return
	}

	// Inisialisasi make() agar kembalian JSON berupa [] bukan null jika kosong
	notifications := make([]models.NotificationResponse, 0)

	for _, res := range results {
		title := "Data Lahan Baru"
		bodyText := fmt.Sprintf("Operator %s telah menginput lahan seluas %.2f Ha di %s.",
			res.NamaOperator, res.LuasLahan, res.LokasiLahan)
		timeStr := res.DateTransaction.Format("02 Jan 2006, 15:04")

		if res.StatusLahan == "2" {
			title = "Lahan Tervalidasi"
			bodyText = fmt.Sprintf("Lahan seluas %.2f Ha di %s telah berhasil divalidasi.", res.LuasLahan, res.LokasiLahan)
			if res.TglValid != "" {
				timeStr = res.TglValid
			}
		}

		notifications = append(notifications, models.NotificationResponse{
			ID:    res.IDLahan,
			Title: title,
			Body:  bodyText,
			Time:  timeStr,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": notifications})
}

// 2. Hitung Notifikasi Belum Dibaca (Badge Merah)
func (nc *NotificationController) GetPendingCount(c *gin.Context) {
	// --- SAYA KOMENTAR SEMENTARA AGAR TIDAK ERROR "UNUSED VARIABLE" ---
	// adminIdTugas, _ := c.Get("id_tugas")
	// if adminIdTugas == nil {
	// 	adminIdTugas = ""
	// }

	var count int64

	err := nc.DB.Table("lahan").
		Where("statuslahan = ?", "1").
		// Where("idtingkat LIKE ?", fmt.Sprintf("%v%%", adminIdTugas)). // <-- Filter dimatikan sementara
		Count(&count).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghitung jumlah notifikasi"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"count": count})
}
