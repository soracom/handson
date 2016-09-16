# SORACOM Canal ＆ Gate ハンズオン

## はじめに
このハンズオンでは、SORACOM と AWS を使用したモバイル閉域網接続環境を実際に構築し、プライベートIPアドレスで端末とEC2インスタンス間で通信が行えることを確認します。

## 前提
本ハンズオンでは、以下を前提としています。

- SORACOM のアカウントをお持ちであること
- SORACOM Air の SIM(Air SIM)、および使用できるデバイス(スマートフォン・タブレット、モバイルルータなど)をお持ちであること
- AWSのアカウントをお持ちであること

### SORACOM のアカウント開設とSIMの登録
SORACOMのアカウントを取得されていない方は、以下のガイドに従い、アカウントの作成と支払情報の設定を行ってください。

- <a target="\_blank" href="https://dev.soracom.io/jp/start/console/#account">アカウントの作成</a>
- <a target="\_blank" href="https://dev.soracom.io/jp/start/console/#payment">支払い情報の設定</a>

既にアカウントをお持ちであるか、上記を済ませた後、SIMの登録をお済ませください。

- <a target="\_blank" href="https://dev.soracom.io/jp/start/console/#registsim">Air SIMの登録</a>

### Amazon VPCについて
VPC について詳しく知りたい方は、以下のガイド(AWS公式ドキュメント)も合わせてご参照ください。

- <a target="\_blank" href="http://docs.aws.amazon.com/AmazonVPC/latest/GettingStartedGuide/">VPC 入門ガイド</a>
- <a target="\_blank" href="http://docs.aws.amazon.com/AmazonVPC/latest/PeeringGuide/">VPC ピアリングの機能解説</a>

## ハンズオンの流れ
ハンズオンは以下のような流れで行います

- SORACOM アカウントの作成 〜 Air SIM の登録
- SORACOM Canal を使ってモバイルで閉域網通信を行う
  - AWS VPC の構築
  - SORACOM Canal の設定
  - デバイスから Canal への疎通確認
- SORACOM Gate を使ってデバイスにアクセスする
  - Gate を有効化する
  - インスタンス上でVXLANの設定を行う
  - インスタンスからデバイスにアクセスする

## SORACOM Canal とは

SORACOM Canal （以下、Canal）は、Amazon Web Services(AWS) 上に構築したお客様の仮想プライベートクラウド環境(Amazon Virtual Private Cloud、以下、VPC)と SORACOM プラットフォームを直接接続するプライベート接続サービスです。

SORACOM プラットフォームは、AWS の VPC 上に構築されています。そのため、VPC 間を接続する「VPC ピアリング」という機能を使うことで、SORACOM の VPC とお客様の VPC を AWS 内で閉じた環境で接続することができます。

Canal でピアリング接続対象の VPC は、AWS のアジアパシフィック(東京)リージョン上となります。

Canal は、Virtual Private Gateway(以下、VPG)とよばれる SORACOM Air とお客様の VPC を仲介するゲートウェイを利用して、お客様の VPC とピアリング接続します。

![Canal Overview 1](img/gs_canal/canal01_overview01.png)

VPG の作成時には、インターネットへのルーティングを行うか、ピアリング先のみにするかを設定することができます。ピアリング先のみを設定した場合は、インターネットアクセスを許可しない完全閉域網となります。

なお、VPG の利用の有無は、SORACOM Air のグループごとに設定できます。

このため、同じ Air SIM であっても所属するグループを変更することで、お客様の VPC へのアクセス可否を切り替えることが可能です。

![Canal Overview 2](img/gs_canal/canal01_overview02.png)

Canal の利用を開始するステップは、以下の通りです。(当ガイドも以下のステップでご紹介します。)

- ステップ 1: [AWS の設定] VPC、および EC2インスタンスを作成する
- ステップ 2: [SORACOM の設定] VPG を作成し、VPCピア接続を設定する
- ステップ 3: [AWS の設定] ピアリング接続を受諾し、ネットワークを設定する
- ステップ 4: 閉域網で接続する

以降、上記の4つのステップにそって、手順をご説明します。なお、ステップ1については、AWS Cloud Formation のテンプレートを用意しています。

## ステップ 1: VPC、および EC2 インスタンスを作成する
ここでは、以下の赤の点線部分を作成します。

![](img/gs_canal/canal02_vpc01.png)

本ハンズオンでは、Cloud Formation テンプレートを使用して VPC、および EC2 インスタンスを作成します。

> もし全て手動で構成をしてみたいという方は、[「SORACOM Canal Getting Started ガイド - ステップ1」](https://dev.soracom.io/jp/start/canal/#step1) を参照下さい。

事前に EC2 インスタンスのキーペアが必要です。まずキーペアを作成してください。

<a target="\_blank" href="https://ap-northeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-1#KeyPairs:sort=keyName">AWS マネジメントコンソールの EC2 ダッシュボード</a> から、「キーペアの作成」を行います。

![](img/gs_canal/canal06_cf01.png)

キーペア名を入力します。

![](img/gs_canal/canal06_cf02.png)

次に、Cloud Formation テンプレートから VPC、EC2 を作成します。

<a target="\_blank" href="https://console.aws.amazon.com/cloudformation/home?region=ap-northeast-1#cstack=sn~canal-test|turl~https://s3.amazonaws.com/soracom-files/canal-ec2.json">こちらのリンク</a> から、CloudFormation の　Stack 作成画面を開き、「Next」をクリックします。

![](img/gs_canal/canal06_cf04.png)

スタックの名前とパラメータを指定します。

- 「Stack name」は任意の名前をつけてください。
- 「KeyName」は先ほど作成したキーペア名となります。
- 「InstanceType」は AWS の無料使用枠を使うのであればデフォルトの「t2.micro」のまま、もし無料枠の対象でない場合には、「t2.nano」に変更してもよいでしょう。

![](img/gs_canal/canal06_cf05.png)

「Next」をクリックします。

![](img/gs_canal/canal06_cf06.png)

「Create」をクリックします。

![](img/gs_canal/canal06_cf07.png)

Status が「CREATE_COMPLETE」となれば作成されています。

![](img/gs_canal/canal06_cf08.png)

必要な情報が「Outputs」タブに表示されているので、ご確認ください。

![](img/gs_canal/canal06_cf09.png)

Outputs の ec2PublicIp に表示されているIPアドレスにPCのブラウザでアクセスしてみましょう。

![](img/gs_canal/canal03_ec209.png)

Apache にアクセスすることができました。

ここでは、グローバル IP アドレスで EC2 にアクセスしていますが、Canal をセットアップすることで、プライベートアドレスでアクセスできるようになります。

以上で、「ステップ 1: VPC、および EC2インスタンスを作成する」は完了です。

## ステップ 2: VPG を作成し、VPC ピア接続を設定する

ここでは、VPG を作成し、VPC ピア接続を設定します。以下の赤の点線部分を作成します。

![](img/gs_canal/canal04_vpg01.png)

###  VPG の作成

SORACOM のユーザーコンソールにログインします。

画面上部のメニューから「閉域網接続」を選択します。

![](img/gs_canal/canal04_vpg02.png)

「VPG を追加」をクリックします。

![](img/gs_canal/canal04_vpg03.png)


VPG の名前を入力し、対象サービスとして「Canal」を選択します。

![](img/gs_canal/canal04_vpg04.png)

> 「インターネットゲートウェイを使う」は、冒頭で紹介したインターネットへのルーティングを行うか、ピアリング先のみにするかの設定となります。  
> 「インターネットゲートウェイを使う」を OFF にした場合は、インターネットアクセスを許可しない完全閉域網となります。ここでは、インタネットゲートウェイを ON にします。

「作成」をクリックすると、以下のように「状態」が「作成中」となります。

![](img/gs_canal/canal04_vpg05.png)

しばらく(3分程度)して、「実行中」となれば作成完了です。

次に、「ステップ１」で作成した VPC にピア接続を設定します。

ピア接続の設定には、以下の情報が必要となります。

- AWS のアカウント番号
- 接続先の VPC ID
- VPC の アドレスレンジ (CIDR)

AWS のアカウント番号は、AWS マネジメントコンソールの右上にある「サポート」→「サポートセンター」をクリックし、表示されるサポートセンターの右上で確認できます。

![](img/gs_canal/canal04_vpg06.png)

![](img/gs_canal/canal04_vpg07.png)

VPC ID と VPC のアドレスレンジ(VPC CIDR)は AWS マネジメントコンソールから VPC ダッシュボードの「VPC」で一覧から確認することができます。

![](img/gs_canal/canal04_vpg08.png)

###  VPC ピア接続の設定

では、ピア接続を設定します。

先ほど作成した VPG を選択します。

![](img/gs_canal/canal04_vpg09.png)

「基本設定」→「VPC ピア接続」から「追加」をクリックします。

![](img/gs_canal/canal04_vpg10.png)

以下の情報を入力して、「作成」をクリックします。

![](img/gs_canal/canal04_vpg11.png)

この操作で、「 ステップ 1: VPC、および EC2 インスタンスを作成する」で作成した VPC に SORACOM からピア接続がリクエストされています。

以上で、「ステップ 2: VPG を作成し、VPC ピア接続を設定します。」は完了です。

## ステップ 3: ピアリング接続を受諾し、ネットワークを設定

ここでは、「ステップ 1: VPC、および EC2 インスタンスを作成する」で作成した VPC で、ピア接続を受諾し、ネットワークの設定(ルートテーブルの設定)を行います。

AWS のマネジメントコンソールから VPC ダッシュボードに移ります。

「VPC ピアリング」を選択します。以下のようにピアリングのリクエストを確認してください。

![](img/gs_canal/canal04_vpg12.png)

当該のピアリングを選択して、「アクション」から「リクエストの承認」を選択してください。

![](img/gs_canal/canal04_vpg13.png)

以下のようなウィンドウが表示されますので、「ルートテーブルを今すぐ変更」を選択し、ルートテーブルを変更します。

![](img/gs_canal/canal04_vpg14.png)

インスタンスが含まれるルートテーブルを選択し、「100.64.0.0/16」を受諾したピアリング接続(pcx-xxxxxx)にします。当ガイドの手順で作成した場合、「１個のパブリックサブネットを持つ VPC」を作成しているので、「明示的に関連付けられた」サブネットが「1 サブネット」と表示されているルートテーブルになります。

VPG のアドレスレンジは、100.64.0.0/16 となりますので、当アドレスの送信先を VPG とします。

![](img/gs_canal/canal04_vpg15.png)

「保存」をクリックします。

以上で、ピア接続の受諾、および、ルートテーブルの設定は完了しました。

## ステップ 4: 閉域網で接続する

いよいよ、Canal を通じて、閉域網の接続を行います。

以下の手順で接続します。

- グループを作成し VPG を設定する
- Air SIM をグループに所属させる
- Air SIM からプライベートアドレスでアクセスします。

###  グループを作成し VPG を設定する

SORACOM ユーザーコンソールから「グループ」を選択します。

![](img/gs_canal/canal05_connect01.png)

「追加」をクリックして、グループ名を入力し、グループを作成します。

![](img/gs_canal/canal05_connect02.png)

作成したグループをクリックしグループ画面の「基本設定」から「SORACOM Air 設定」を開きます。

![](img/gs_canal/canal05_connect03.png)

「SORACOM Air 設定」内に、以下のように「VPG (Virtual Private Gateway) 設定」がありますので、「ON」とし、ステップ2で作成した「VPG」を選択します。

![](img/gs_canal/canal05_connect04.png)

「保存」をクリックします。

> VPG を指定したグループに含まれる Air SIM は VPG を利用することになります。  
> Air SIM の所属するグループを切り替えることで、同じ Air SIM であっても VPG を利用する/しないを切り替えることができます。これにより、閉域網接続の可否を切り替えることができます。

###  Air SIM をグループに所属させる
「SIM 管理」メニューから、接続を行う SIM を選択し、「所属グループ変更」をクリックします。

![](img/gs_canal/canal05_connect05.png)

先ほど作成したグループに所属させます。

![](img/gs_canal/canal05_connect06.png)

### SIMを再接続する(重要)

SIMが接続するVPGの設定を変更しましたので、既に接続中のデバイスについては、設定変更後に一旦接続を切ってから繋ぎ直してください。

再接続する方法には、以下があります

- デバイスが手元にある場合
  - スマホ・タブレット等：Air Plane (＜機内＞)モードがある場合 On / Off
  - ラズパイ等の場合：3G/LTEの再接続(pppのリスタートなど)
  - その他：デバイス自体の再起動
- デバイスが遠隔地にある場合
  - ユーザコンソールから、当該のSIM を一旦「休止」して、再度「使用開始」を行う
  - <a target="\_blank" href="https://dev.soracom.io/jp/docs/api/#!/Subscriber/deleteSubscriberSession">deleteSubscriberSession API</a>を実行する

###  Air SIM からプライベートアドレスでアクセスする

VPG を使用するグループから、「ステップ 1: VPC、および EC2 インスタンスを作成する」で作成した VPC 内の EC2 インスタンスにアクセスします。

ブラウザを起動し、EC2 インスタンスのプライベートアドレスを入力します。

プライベートアドレスである「10.0.0.254」でアクセスできています！

![](img/gs_canal/canal05_connect07.png)

以上で、「SORACOM Canal を使用して閉域網でサーバーに接続する」は完了です。

Canal を利用することにより、インターネットを介することなく、VPC にアクセスすることが可能となります。また、 VPC もインターネットにポートを開ける必要はありません。

当ガイドでは、VPG のインターネットゲートウェイを「ON」として作成しましたが、「OFF」(ピア接続先のみ)を設定した場合は、インターネットアクセスを許可しない完全閉域網となります。インターネットからデバイスにマルウエアを仕込まれるリスクを回避することも可能となります。
