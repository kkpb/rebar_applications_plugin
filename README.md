rebar_applications_plugin
=========================

アプリケーションリソースファイル(.app)内の`applications`項目を自動で生成するための[rebar](https://github.com/rebar/rebar)プラグイン。

なお`applications`は、そのアプリケーションが依存するアプリケーション群を指定するための項目。

参照: http://www.erlang.org/doc/man/app.html

注意
----

このプラグインは、他のアプリケーションから参照されるようなアプリケーションでの使用は想定されていません。<br />
(参照ツリーの一番ルートとなるアプリケーションでの使用のみが想定されている)

使い方
------

[rebar.config](https://github.com/rebar/rebar/blob/master/rebar.config.sample)に以下の項目を追加することで、このプラグインを有効にできる。<br />
※ なお、このプラグインはアプリケーションのコンパイル後に自動で適用される。
```erlang
%%%
%%% in rebar.conrig
%%%

%% プラグインのソースが配置されているディレクトリを指定する
{plugin_dir, "deps/rebar_applications_plugin/src"}.

%% 使用するプラグインを指定する
{plugins, [rebar_applications_plugin]}.

%% このプラグインに指定可能なオプション (省略可)
%% - include_system_lib:
%%   - code:lib_dir()以下に配置されているライブラリ群を依存性解析対象に含めるかどうか
%%   - 含めた場合、処理時間が長くなってしまうので、デフォルトはfalse
%% - exclude_apps:
%%   - 解析対象から除外するアプリケーション群を指定する
%%   - デフォルトは[]
{fill_apps_opts, [{include_system_lib, false},
                  {exclude_apps, [hoge, fuga]}]}.

%% 依存ライブラリに追加する
{deps,
  [
   {rebar_applications_plugin, ".*",
     {git, "https://github.com/sile/rebar_applications_plugin", {tag, "v0.1.2"}}}
  ]}.
```


自動生成ルール
--------------

このプラグインの細かい動作について記述する。

### 基本ルール

基本的には[xref](http://www.erlang.org/doc/man/xref.html)を用いたアプリケーション間の依存関係を解析し、`applications`項目の値を生成している。<br />
(ex: 対象アプリケーション内で`OtherApplication:hoge/2`という関数を使用しているモジュールがあるなら、`OtherApplication`を`applications`に追加する)

ただし、`*.app.src`内の`applications`項目に手動で記述されているアプリケーション群に関しては、特に変更を加えることなくそのまま使用される。<br />
(プラグインが生成したアプリケーション群に関しては、重複が除去された上で、末尾に追加される)

この基本ルールに加えて、アプリケーションの種類に応じて、以下のように挙動が変わる。

### 依存アプリケーションの場合

`rebar.config`の`deps`項目で指定されているアプリケーション群のこと。

これらのアプリケーション群のアプリケーションリソースファイルは、自動生成の対象からは除外される。<br />
(依存性解析の対象には含まれる)


### サブアプリケーションの場合

`rebar.config`の`sub_dirs`項目で指定されているアプリケーション群のこと。

基本的には通常と同様に依存性が解析されるが、アプリケーション間の循環参照の可能性を無くすために、
(`sub_dirs`項目上で)自分よりも後ろに位置するアプリケーションおよびルートアプリケーションは、
強制的に依存先からは除外される。

そのため、特定のサブアプリケーションが別のサブアプリケーションに対して(起動順に対して敏感な)依存性を
保持している場合は、`sub_dirs`項目内での並び順を調整することで、依存性を指定するようにする必要がある。


### ルートアプリケーションの場合

メインとなる`rebar.config`を保持するアプリケーションのこと。

ルートアプリケーションの`applications`項目には、全てのサブアプリケーション群が自動で追加される。


補足: `applications`項目の役割
------------------------------

アプリケーションリソースファイル(*.app)内の`applications`項目は、
そのアプリケーションが依存しているアプリケーション群を記述するための項目で、
主に以下の用途で使用される。
- `application:start/1`呼び出し時の依存性チェック
  - 上記関数(およびその派生関数群)は、指定されたアプリケーションの起動時に、それが依存しているアプリケーション群が全て起動済みであることを要求する
  - `application:ensure_all_started/1`を使うと、未起動の依存アプリケーションがあれば、(再帰的に)それらを全て起動した上で、指定アプリケーションを起動してくれるので便利
- リリース物に含めるアプリケーション群の決定
  - リリース管理ツールである[reltool](http://www.erlang.org/doc/man/reltool.html)の設定ファイル(reltool.config)では`rel`項目でリリースパッケージに含めるアプリケーション群を指定する
  - そこで指定されたアプリケーションおよび、それが(再帰的に)依存する全てのアプリケーションがリリースパッケージに含まれることになる
  - `applications`項目が適切に記述されていれば、ルートとなるアプリケーションだけを指定すれば良くなるので、依存アプリケーションの増減に伴う記述修正の手間が減る

なお、複数アプリケーション間に循環する依存関係が指定されている場合は`application:ensure_all_started/1`の呼び出し時等に、無限ループとなってしまうので注意が必要。<br />


gen_deps_graph
===============

アプリケーション間の依存関係を表したグラフを生成するためのツール。

- 依存関係の解析には[xref](http://www.erlang.org/doc/man/xref.html)を使用
- 生成するグラフの書式は[graphviz](http://www.graphviz.org/)に準拠

使い方
------

```bash
# ビルド
$ make script

# ヘルプ
$ ./gen_deps_graph
Usage: gen_deps_graph call|use DEPTH ROOT_APPLICATION[,ROOT_APPLICATION]* [EXCLUDE_APPLICATION[,EXCLUDE_APPLICATION]*]

# 実行例: cryptoが直接(DEPTH=1)使用しているアプリケーションのグラフ
$ DEPTH=1
$ ./gen_deps_graph call $DEPTH crypto
digraph crypto {
 crypto -> kernel;
 crypto -> stdlib;
}

# 実行例: cryptoを直接(DEPTH=1)使用しているアプリケーションのグラフ
$ ./gen_deps_graph use $DEPTH crypto
digraph crypto {
 common_test -> crypto;
 compiler -> crypto;
 public_key -> crypto;
 snmp -> crypto;
 ssh -> crypto;
 ssl -> crypto;
 stdlib -> crypto;
}

# PNG形式に変換
$ ./gen_deps_graph use $DEPTH crypto | dot -Tpng -o crypto.png /dev/stdin
```
