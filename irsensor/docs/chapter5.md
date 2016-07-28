## <a name="chapter5">5章 赤外線リモコンの信号を解析する
- [プログラムのダウンロード](#section5-1)
- [LIRCとは](#section5-2)
- [LIRCのインストール](#section5-3)
- [配線](#section5-4)
- [センサーの動作確認](#section5-5)
- [赤外線信号のデータを取得する](#secion5-6)
- [応用編](#secion5-7)

### プログラムのダウンロード  
`curl -O hogehoge`

###  LIRCとは？  
Linux Infrared Remote Controlの略で、Linux上での赤外線信号の送受信のコントロールを簡単にできるようにするためのライブラリです。今回はこのライブラリを使うことによって、送信したい赤外線信号の解析および送信を行っていきます。

### LIRCのインストール
- LIRCをインストールする  
`$ sudo apt-get install lirc`

- LIRCを有効にする  
`$ sudo vim /etc/lirc/hardware.conf`
hardware.confを以下のコマンドを用いて修正する。

```
$ cp /etc/lirc/hardware.conf ~/hardware.conf // バックアップを取る
$ sudo ./ir_tools/edit_hardware_conf.sh // hardware.confを編集
```

- 起動時にLIRCを有効にする。

```
$ sudo ./ir_tools/edit_boot_conf.sh // boot/config.txt の末尾にdtoverlay=lirc-rpi,gpio_in_pin=22,gpio_out_pin=23を追加
```

- Raspberry Piを再起動する  
`$ sudo reboot`

- 有効になっているか確認  
下記コマンドを実行して`lirc_rpi`が表示されていることを確認する。
```
$ lsmod | grep lirc
  lirc_rpi                6638  0
  lirc_dev                8169  1 lirc_rpi
  rc_core                16956  1 lirc_dev
```

- LIRCを停止する  
`$ sudo /etc/init.d/lirc stop`

### 配線

### センサーの動作確認
上記コマンドを実行した後、センサーに向かってリモコンのボタンを押す。
このとき、下記のような数字列が出力されることを確認する。

```
$ mode2 -md /dev/lirc0

```

### 赤外線信号のデータを取得する
- 信号の解析データを保存する。  
待機状態になるので、赤外線受信モジュールにリモコンを向けて、一度だけ電源オンボタンを押してください。  
下記コマンドで赤外線信号を解析したデータがpower_on.datに保存されます。  
`$ mode2 -md /dev/lirc0 | tee power_on.dat`

- 信号の解析データを設定ファイルに書き込む   
下記コマンドを実行して、登録名を表示してくださいとでてきたらpower_onと入力。
```
$ sudo ruby ir_tools/irrecord.rb power_on.dat
登録名を入力してください (Ex: switch_on)
power_on
```

### 応用編
- 追加で信号の解析データを保存する。  
待機状態になるので、赤外線受信モジュールにリモコンを向けて、登録したいボタンを一度だけ押してください。    
`$ mode2 -md /dev/lirc0 | tee <ボタンの名称(任意のファイル名も可)>.dat`

- 信号の解析データを設定ファイルに書き込む   
下記コマンドを実行して、登録名を表示してくださいとでてきたら「ボタンの名称」を入力。
```
$ sudo ruby ir_tools/irrecord.rb power_on.dat
ボタンの名称を入力してください (Ex: switch_on)
<power_off等の任意のボタンの名称を入力>
```
これで追加のボタンの信号データが登録されました。  

- 登録されたボタンの一覧を確認する  
`$ irsend LIST controller ""`

- 登録したボタンの信号を送信する  
9章の「SORACOM Beam経由で赤外線信号を送信する」で命令を上記で登録したものに変更すると、新しく登録した赤外線信号が送信できます。
