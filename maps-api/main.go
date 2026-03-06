package main

import (
	"database/sql"
	"encoding/json"
	"errors"
	"log"
	"math"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	_ "github.com/mattn/go-sqlite3"
)

type Location struct {
	ID        int64     `json:"id"`
	UserID    string    `json:"user_id"`
	Label     string    `json:"label"`
	Lat       float64   `json:"lat"`
	Lng       float64   `json:"lng"`
	CreatedAt time.Time `json:"created_at"`
}

type CreateLocationReq struct {
	UserID string  `json:"user_id"`
	Label  string  `json:"label"`
	Lat    float64 `json:"lat"`
	Lng    float64 `json:"lng"`
}

func main() {
	dbPath := env("DB_PATH", "./data.db")
	port := env("PORT", "8080")

	db, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	if err := initSchema(db); err != nil {
		log.Fatal(err)
	}

	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(10 * time.Second))
	r.Use(middleware.Logger)

	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{"ok": true})
	})

	r.Route("/locations", func(r chi.Router) {
		r.Post("/", handleCreateLocation(db))
		r.Get("/", handleListLocations(db))
		r.Get("/count", handleCountLocations(db))
		r.Get("/near", handleNearLocations(db))
	})

	log.Printf("listening on :%s (db=%s)", port, dbPath)
	log.Fatal(http.ListenAndServe(":"+port, r))
}

func initSchema(db *sql.DB) error {
	_, err := db.Exec(`
CREATE TABLE IF NOT EXISTS locations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  label TEXT NOT NULL DEFAULT '',
  lat REAL NOT NULL,
  lng REAL NOT NULL,
  created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_locations_user_id ON locations(user_id);
CREATE INDEX IF NOT EXISTS idx_locations_created_at ON locations(created_at);
`)
	return err
}

func handleCreateLocation(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req CreateLocationReq
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			writeErr(w, http.StatusBadRequest, "invalid_json")
			return
		}

		req.UserID = strings.TrimSpace(req.UserID)
		req.Label = strings.TrimSpace(req.Label)

		if req.UserID == "" {
			writeErr(w, http.StatusBadRequest, "user_id_required")
			return
		}
		if !isValidLatLng(req.Lat, req.Lng) {
			writeErr(w, http.StatusBadRequest, "invalid_lat_lng")
			return
		}

		now := time.Now().UTC().Format(time.RFC3339Nano)
		res, err := db.Exec(
			`INSERT INTO locations (user_id, label, lat, lng, created_at) VALUES (?, ?, ?, ?, ?)`,
			req.UserID, req.Label, req.Lat, req.Lng, now,
		)
		if err != nil {
			writeErr(w, http.StatusInternalServerError, "db_insert_failed")
			return
		}

		id, _ := res.LastInsertId()
		writeJSON(w, http.StatusCreated, map[string]any{"id": id})
	}
}

func handleListLocations(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := strings.TrimSpace(r.URL.Query().Get("user_id"))

		limit := parseInt(r.URL.Query().Get("limit"), 50)
		offset := parseInt(r.URL.Query().Get("offset"), 0)
		if limit <= 0 || limit > 200 {
			limit = 50
		}
		if offset < 0 {
			offset = 0
		}

		var (
			rows *sql.Rows
			err  error
		)

		if userID == "" {
			rows, err = db.Query(
				`SELECT id, user_id, label, lat, lng, created_at
				 FROM locations
				 ORDER BY id DESC
				 LIMIT ? OFFSET ?`,
				limit, offset,
			)
		} else {
			rows, err = db.Query(
				`SELECT id, user_id, label, lat, lng, created_at
				 FROM locations
				 WHERE user_id = ?
				 ORDER BY id DESC
				 LIMIT ? OFFSET ?`,
				userID, limit, offset,
			)
		}
		if err != nil {
			writeErr(w, http.StatusInternalServerError, "db_query_failed")
			return
		}
		defer rows.Close()

		out := make([]Location, 0, limit)
		for rows.Next() {
			var loc Location
			var createdAtStr string
			if err := rows.Scan(&loc.ID, &loc.UserID, &loc.Label, &loc.Lat, &loc.Lng, &createdAtStr); err != nil {
				writeErr(w, http.StatusInternalServerError, "db_scan_failed")
				return
			}
			t, err := time.Parse(time.RFC3339Nano, createdAtStr)
			if err == nil {
				loc.CreatedAt = t
			}
			out = append(out, loc)
		}

		writeJSON(w, http.StatusOK, map[string]any{
			"items":  out,
			"limit":  limit,
			"offset": offset,
		})
	}
}

func handleCountLocations(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID := strings.TrimSpace(r.URL.Query().Get("user_id"))

		var (
			cnt int64
			err error
		)

		if userID == "" {
			err = db.QueryRow(`SELECT COUNT(1) FROM locations`).Scan(&cnt)
		} else {
			err = db.QueryRow(`SELECT COUNT(1) FROM locations WHERE user_id = ?`, userID).Scan(&cnt)
		}
		if err != nil {
			writeErr(w, http.StatusInternalServerError, "db_count_failed")
			return
		}

		writeJSON(w, http.StatusOK, map[string]any{"count": cnt})
	}
}

func handleNearLocations(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		lat := parseFloat(r.URL.Query().Get("lat"), math.NaN())
		lng := parseFloat(r.URL.Query().Get("lng"), math.NaN())
		if math.IsNaN(lat) || math.IsNaN(lng) || !isValidLatLng(lat, lng) {
			writeErr(w, http.StatusBadRequest, "lat_lng_required")
			return
		}

		radiusM := parseFloat(r.URL.Query().Get("radius_m"), 1000)
		if radiusM <= 0 || radiusM > 100000 {
			radiusM = 1000
		}

		userID := strings.TrimSpace(r.URL.Query().Get("user_id"))

		// Ambil kandidat dari DB (tanpa PostGIS kita filter manual di app layer).
		// Untuk skala kecil-menengah ini OK. Untuk skala besar => Postgres + PostGIS.
		var (
			rows *sql.Rows
			err  error
		)
		if userID == "" {
			rows, err = db.Query(`SELECT id, user_id, label, lat, lng, created_at FROM locations`)
		} else {
			rows, err = db.Query(`SELECT id, user_id, label, lat, lng, created_at FROM locations WHERE user_id = ?`, userID)
		}
		if err != nil {
			writeErr(w, http.StatusInternalServerError, "db_query_failed")
			return
		}
		defer rows.Close()

		out := make([]map[string]any, 0, 50)
		for rows.Next() {
			var loc Location
			var createdAtStr string
			if err := rows.Scan(&loc.ID, &loc.UserID, &loc.Label, &loc.Lat, &loc.Lng, &createdAtStr); err != nil {
				writeErr(w, http.StatusInternalServerError, "db_scan_failed")
				return
			}
			dist := haversineMeters(lat, lng, loc.Lat, loc.Lng)
			if dist <= radiusM {
				out = append(out, map[string]any{
					"id":         loc.ID,
					"user_id":    loc.UserID,
					"label":      loc.Label,
					"lat":        loc.Lat,
					"lng":        loc.Lng,
					"distance_m": dist,
					"created_at": createdAtStr,
				})
			}
		}

		writeJSON(w, http.StatusOK, map[string]any{
			"center":   map[string]any{"lat": lat, "lng": lng},
			"radius_m": radiusM,
			"count":    len(out),
			"items":    out,
		})
	}
}

func haversineMeters(lat1, lon1, lat2, lon2 float64) float64 {
	const R = 6371000.0
	phi1 := lat1 * math.Pi / 180
	phi2 := lat2 * math.Pi / 180
	dphi := (lat2 - lat1) * math.Pi / 180
	dlam := (lon2 - lon1) * math.Pi / 180

	a := math.Sin(dphi/2)*math.Sin(dphi/2) +
		math.Cos(phi1)*math.Cos(phi2)*math.Sin(dlam/2)*math.Sin(dlam/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
	return R * c
}

func isValidLatLng(lat, lng float64) bool {
	if lat < -90 || lat > 90 {
		return false
	}
	if lng < -180 || lng > 180 {
		return false
	}
	return true
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

func writeErr(w http.ResponseWriter, status int, code string) {
	writeJSON(w, status, map[string]any{
		"error": map[string]any{
			"code": code,
		},
	})
}

func env(key, fallback string) string {
	v := strings.TrimSpace(os.Getenv(key))
	if v == "" {
		return fallback
	}
	return v
}

func parseInt(s string, def int) int {
	if strings.TrimSpace(s) == "" {
		return def
	}
	n, err := strconv.Atoi(s)
	if err != nil {
		return def
	}
	return n
}

func parseFloat(s string, def float64) float64 {
	if strings.TrimSpace(s) == "" {
		return def
	}
	f, err := strconv.ParseFloat(s, 64)
	if err != nil {
		return def
	}
	return f
}

var _ = errors.New