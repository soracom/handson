## <a name="chapter9">9章 SORACOM Beam経由で赤外線信号を送信する
- 全体構成
- Raspberry Piにプログラムをダウンロード
- ホストPCにプログラムをダウンロード
- SORACOM Beam経由で赤外線信号を送信する

### 全体構成
![](images/demo_pic.png)

### Raspberry Piにプログラムをダウンロード

- プログラムをダウンロード  
`pi@raspberrypi:~ $ curl -O hogehoge`

- MQTTクライアントをインストール  
`pi@raspberrypi:~ $ sudo gem install mqtt`

- 環境変数を設定する  
`pi@raspberrypi:~ $ export MQTT_USERNAME=<Sangoで取得したユーザ名>`

- スクリプトをダウンロードしてMQTTを受信する
```
pi@raspberrypi:~ $ wget https://s3-ap-northeast-1.amazonaws.com/soracom-demo/ir_tools/subscriber.rb
pi@raspberrypi:~ $ ruby ir_tools/subscriber.rb
```

上記のプログラムを起動したまま別のタブでホストPCにログイン
### ホストPCでMQTTをsubscribe
- MQTTクライアントをインストール  
`$ gem install mqtt`

- 環境変数を設定する

```
$ export MQTT_PASSWORD=<Sangoで取得したパスワードを入力>
$ export MQTT_USERNAME=<Sangoで取得したユーザ名>
```
- スクリプトをダウンロード・実行してMQTTを送信し、赤外線信号が送信されることを確認
```
$ wget https://s3-ap-northeast-1.amazonaws.com/soracom-demo/ir_tools/publisher.rb
$ ruby publisher.rb power_on
```
power_onを他の命令に変えることで他の信号も送信できます。  
詳しくは「5章　応用編」を参照してください。  

おつかれさまでした！！
以上でハンズオンは終了です。
