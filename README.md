2ch_jimaku
==========

2ch互換掲示板用の字幕表示ソフト

# 開発環境

### 【Adobe Air 14.0】
http://get.adobe.com/jp/air/  
### 【Adobe AIR SDK & Compiler】
http://www.adobe.com/devnet/air/air-sdk-download.html  
### 【CoffeeScript】
node.jsがインストールされている事が前提  
`sudo npm install -g coffee-script`  
プロジェクトルートディレクトリへ移動  
`cd project_root`  
CoffeeScriptビルドコマンド  
 `# coffee (オプション) (保存先パス/ファイル名) (coffeeファイルがある場所)`  
`coffee -bwc -j js/scripts.js .`  
上記のコマンドを実行した後にcoffeeファイルを編集すると、変更前との差分を検知し、自動的にビルドされた後にjs/scripts.jsファイルに保存されます。  
### 【その他】
haml  
scss  

#説明

ロジック系はcoffeeフォルダ内を参照 。  
main.coffeeでクリックイベントを受け取り各インスタンスを操作しています。  
現在対応している掲示板はしたらばのみ  

#実装・改良したい機能

・板登録機能  
・したらば旧URL、＠chs、２ちゃんねるに対応  
・ウィンドウの位置・サイズの記憶機能  
・フォント、フォントサイズ、フォントカラーの変更機能  
・レスのURLリンク化  
・main.coffeeのリファクタリング  

#使用素材

【同封レス着信音】  
魔王魂  
http://maoudamashii.jokersounds.com/music_se.html  
【フォントアイコン】  
Font Awedome  
http://fortawesome.github.io/Font-Awesome/  