Google Cloud Platformのアカウント作成とセットアップ
===

## Google Cloud Platformとは？
Google Cloud Platformとは、Googleが提供しているクラウドサービスをまとめた総称です。Googleが社内で利用しているテクノロジーと同等のものをサービスとして提供していることが特徴のクラウドサービスです。

## Google Cloud Platformのアカウント開設
本ハンズオンでは、初めてGCPのアカウントを開設する方を対象としています。GCPには、初めてサインアップされた方向けに無料トライアルの期間が設けられています。本ハンズオンは複数のGCPコンポーネントを利用しますが、基本的には無料トライアルの範囲内で収まるようになっています。アカウント開設の詳細なステップは、[Google Cloud Platformの簡単スタートアップガイド](https://docs.google.com/presentation/d/1LPBAnXSncyKCFDKC1KgDrTFYoWmx2DD9otfID-6t6Fk/edit#slide=id.p)のP11-P20を参考にアカウント開設を完了させてください。


## Google Cloud SDKの設定
本ハンズオンでは、GCPの各種コンポーネントの起動/設定/停止等を行うために、Google Cloud SDK (gcloudコマンド) が使えるようになる必要があります。Google Cloud SDKが利用可能になる方法としては2つあります。

1. Google Cloud Shellを使う
2. Google Cloud SDKをローカルマシンにインストールする

双方にはメリット・デメリットがあるため、ユーザーの状況に合わせて選択します。本セッションでは、設定の容易性などから、Google Cloud Shellを使う方法を選択します。Google Cloud Shellは、Google Cloud SDKなどのGCPに必要となる各種ツール類がインストール済みのシェルがブラウザから利用可能になるというものです。Google Cloud Shellは、GCPのコンソールから1クリックで立ち上げて利用することが可能になります。詳しくは、
[Google Cloud Platformの簡単スタートアップガイド](https://docs.google.com/presentation/d/1LPBAnXSncyKCFDKC1KgDrTFYoWmx2DD9otfID-6t6Fk/edit#slide=id.p)のP23-P25を参照してください。また、Cloud Shellに予めインストールされているツール群については[こちら](
https://cloud.google.com/shell/docs/features?hl=ja#persistent_disk_storage)よりご確認ください。


## 本ハンズオンで利用するGCPのサービス

本ハンズオンで利用するGCPのサービスは以下のものになります。
- [Cloud Pub/Sub](https://cloud.google.com/pubsub/?hl=ja)
- [BigQuery](https://cloud.google.com/bigquery/?hl=ja)
- [App Engine](https://cloud.google.com/appengine/?hl=ja)
- [Cloud Datalab](https://cloud.google.com/datalab/?hl=ja)

### Cloud Pub/Sub
- Pub/Sub自体の説明と簡単な使い方を追加する

### BigQuery
- BigQuery自体の説明と簡単な使い方を追加する

### App Engine
- AppEngine自体の説明と簡単な使い方を追加する

### Cloud Datalab
- Datalab自体の説明と簡単な使い方を追加する
