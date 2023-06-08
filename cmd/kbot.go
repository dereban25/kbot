/*
Copyright © 2023 NAME HERE <EMAIL ADDRESS>

*/
package cmd

import (
	"fmt"
	"log"
	"os"
	"time"
	"encoding/json"
	"io/ioutil"
	"net/http"
	"github.com/go-telegram-bot-api/telegram-bot-api"
	"github.com/spf13/cobra"
	telebot "gopkg.in/telebot.v3"
)

var (
	TeleToken = os.Getenv("TELE_TOKEN")
)

// kbotCmd represents the kbot command
var kbotCmd = &cobra.Command{
	Use:     "kbot",
	Aliases: []string{"start"},
	Short:   "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("kbot %s started", appVersion)
		kbot, err := telebot.NewBot(telebot.Settings{
			URL:    "",
			Token:  TeleToken,
			Poller: &telebot.LongPoller{Timeout: 10 * time.Second},
		})
		if err != nil {
			log.Fatalf("Please check TELE_TOKEN env variable  . %s", err)
			return
		}
		kbot.Handle(telebot.OnText, func(m telebot.Context) error {
			log.Print(m.Message().Payload, m.Text())
			payload := m.Message().Payload

			switch payload {
			case "hello":
				err = m.Send(fmt.Sprintf("Hello I'm Kbot %s!", appVersion))
			}

			return err

		})

		kbot.Start()
	},
}

func init() {
	rootCmd.AddCommand(kbotCmd)
}
bot, err := tgbotapi.NewBotAPI(TeleToken)
if err != nil {
    log.Fatal(err)
}

type WeatherResponse struct {
	Main struct {
		Temperature float64 `json:"temp"`
	} `json:"main"`
}

func main() {
	// Замініть API_KEY на ваш ключ API OpenWeatherMap
	apiKey := "fbec0b8c8471318ef3f141f4f0651355"
	city := "Kyiv"
	url := fmt.Sprintf("http://api.openweathermap.org/data/2.5/weather?q=%s&appid=%s&units=metric", city, apiKey)

	response, err := http.Get(url)
	if err != nil {
		fmt.Println("Помилка при виконанні HTTP-запиту:", err)
		return
	}
	defer response.Body.Close()

	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		fmt.Println("Помилка при читанні відповіді:", err)
		return
	}

	weather := WeatherResponse{}
	err = json.Unmarshal(body, &weather)
	if err != nil {
		fmt.Println("Помилка при розпакуванні JSON:", err)
		return
	}

	temperature := weather.Main.Temperature
	fmt.Printf("Погода в місті %s: %.1f °C\n", city, temperature)
}