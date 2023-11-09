# Memoアプリ
Sinatraで作成した単純シンプルなメモアプリです。メモの作成、編集、削除といった操作が行えます。

### データベースの作成
Postgresqlのインストール
```
brew update
brew install postgresql
```
Postgresqlの起動
```
brew services start postgresql
```
Postgresqlにログイン
```
psql postgres
```
ユーザーの登録をする
```
CREATE USER ユーザー名 WITH SUPERUSER;
```
登録したユーザーでログイン
```
\q
psql postgres -U ユーザー名
```
"memo_app"というデータベースの作成
```
CREATE DATABASE memo_app;
```
### Memoアプリの本体
リポジトリの複製
```
git clone https://github.com/matuaya/memo-app.git
```
ディレクトリに移動
```
cd memo-app
```
ブランチを変更
```
git checkout memo-app-db
```
プログラムを実行
```
bundle exec ruby app.rb
```
http://localhost:4567 でアクセス
