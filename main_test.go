package main

import (
	"net/http"
	"testing"

	_ "github.com/jinzhu/gorm/dialects/mysql"
	"github.com/labstack/echo"
)

func TestMainPage(t *testing.T) {
	type args struct {
		c echo.Context
	}
	tests := []struct {
		name    string
		wantErr bool
	}{
		{
			name:    "first test",
			wantErr: false,
		},
	}
	for _, tt := range tests {
		e := echo.New()
		r, _ := http.NewRequest("GET", "/hello", nil)
		w := &http.Response{}
		ctx := e.NewContext(r, w)

		t.Run(tt.name, func(t *testing.T) {
			if err := MainPage(ctx); (err != nil) != tt.wantErr {
				t.Errorf("MainPage() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
