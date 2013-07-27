# Corona SDK test runner

Corona SDK で作ったアプリケーション用の単体テスト実行環境を提供します。

この環境をセットアップするとアプリケーション開始時に単体テストが実行されるようになります。
単体テストがひとつでも失敗するとテスト結果を表示する画面が表示されます。
単体テストが全て成功した場合はアプリケーションが開始されます。

## セットアップ

### Mac OS X

````
$ cd プロジェクトディレクトリ
$ \curl -L http://bit.ly/corona-test-runner | bash
````

セットアップにより `main.lua` は `app_main.lua` へ移動されます。

`_test.lua` で終わるファイルはテストのテンプレートファイルです。

### テストの書き方

テストは [lunatest](https://github.com/silentbicycle/lunatest) の記法に従って記述します。

````
-- sample_test.lua
module(..., package.seeall)

function test_double()
   assert_equal(5 * 2, 10)
end
````

テストファイル一覧を `test_main` の `suite()` 引数に指定します。

````
-- main.lua
-- Main
require("test_main"):suite{
   "sample_test",
}:run{
   -- skip = true, -- Skip tests and execute main (For production)
   -- main = "_main", -- Specify application main
}
````
