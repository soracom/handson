# ラズパイ x ソラコムキャンペーン 植物観察キット

## はじめに
このドキュメントは、ラズパイ(Raspberry Pi)と SORACOM の SIM を使って、植物などを定点観測するための仕組みを作る方法を解説します。

静止画を撮りためていくと、以下の様な動画を作成する事も可能なので、ぜひお試し下さい。

<!--
<iframe width="420" height="315" src="https://www.youtube.com/embed/3--gMeGOV1I" frameborder="0" allowfullscreen></iframe>
-->

## 概要
このキットを使うと、以下のような事ができます。

- 温度センサーからの温度データを、毎分クラウドにアップロードし、可視化(グラフ化)する
- USBカメラで静止画を取り、クラウドストレージにアップロードして、スマホなどから確認する
- 撮りためた静止画を繋げて、タイムラプス動画を作成する

これを使って、植物などの成長を観察してみましょう。

## 必要なもの
1. SORACOM Air で通信が出来ている Raspberry Pi  
 - Raspberry Pi に Raspbian (2016-05-27-raspbian-jessie-lite.img を使用)をインストール
 - Raspberry Pi へ ssh で接続ができる(またはモニターやキーボードを刺してコマンドが実行出来る)
 - Raspberry Pi から SORACOM Air で通信が出来ている

  事前にこちら(TODO:リンクする)のテキストを参考に、SORACOM Air の接続ができているものとします
2. ブレッドボード
3. 温度センサー DS18B20+  
  Raspberry Piには接続しやすい、ADコンバータのいらない温度センサー
4. 抵抗 4.7 kΩ
  プルアップ抵抗
5. ジャンパワイヤ(オス-メス) x 3 (黒・赤・その他の色の３本を推奨)
6. USB接続のWebカメラ(Raspbianで認識出来るもの)

## 温度センサーを接続する
Raspberry Pi の GPIO(General Purpose Input/Output)端子に、温度センサーを接続します。

![GPIOピン](image/raspi_pin.png)

使うピンは、3.3Vの電源ピン(01)、Ground、GPIO 4の３つです。
