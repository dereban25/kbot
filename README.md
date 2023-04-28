# kbot

https://t.me/kbotdevops_bot

Find in telegram application chat wirh BotFather
Generate name and nickname bot
After that generate token
Run command in terminal:
1. read -s TELE_TOKEN and insert token
2. export TELE_TOKEN
3. Build project go build -ldflags "-X="github.com/dereban25/kbot/cmd.appVersion=v1.0.3
4. Run bot ./kbot start