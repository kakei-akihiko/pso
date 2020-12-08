# PowerShellでオセロ

## はじめに

PowerShellだったら、途中経過をファイルに保存することなくオセロを実装できますね。

というわけで作ってみました。

## 使い方

※`.ps1`ファイルなので、管理者権限でPowerShellを起動して、`Set-ExecutionPolicy`でファイルの実行を許可しておいてください。

```powershell
Set-ExecutionPolicy RemoteSigned
```

```powershell
> # 開始
> $board = .\Othello.ps1;
> 
> # 盤面表示
> $board.Show()

A  B  C  D  E  F  G  H  Index
-  -  -  -  -  -  -  -  -----
　 　 　 　 　 　 　 　     0
　 　 　 　 　 　 　 　     1
　 　 　 　 　 　 　 　     2
　 　 　 〇 ●  　 　 　     3
　 　 　 ●  〇 　 　 　     4
　 　 　 　 　 　 　 　     5
　 　 　 　 　 　 　 　     6
　 　 　 　 　 　 　 　     7
>
> # 手番
> $board.Set('F4')
●を置きました。次は〇

A  B  C  D  E  F  G  H  Index
-  -  -  -  -  -  -  -  -----
　 　 　 　 　 　 　 　     0
　 　 　 　 　 　 　 　     1
　 　 　 　 　 　 　 　     2
　 　 　 〇 ●  　 　 　     3
　 　 　 ●  ●  ●  　 　     4
　 　 　 　 　 　 　 　     5
　 　 　 　 　 　 　 　     6
　 　 　 　 　 　 　 　     7

>
```

## 自動再生

PowerShellなので次のようにパイプラインで配列を渡せばプレーを自動再生できます。

```powershell
> $board = .\Othello.ps1; $board.Show()

A  B  C  D  E  F  G  H  Index
-  -  -  -  -  -  -  -  -----
　 　 　 　 　 　 　 　     0
　 　 　 　 　 　 　 　     1
　 　 　 　 　 　 　 　     2
　 　 　 〇 ●  　 　 　     3
　 　 　 ●  〇 　 　 　     4
　 　 　 　 　 　 　 　     5
　 　 　 　 　 　 　 　     6
　 　 　 　 　 　 　 　     7

> 'F4','D5','C4','F3','E2','F5','G4','E5','E6' | %{$board.Set($_)}
●を置きました。次は〇

A  B  C  D  E  F  G  H  Index
-  -  -  -  -  -  -  -  -----
　 　 　 　 　 　 　 　     0
　 　 　 　 　 　 　 　     1
　 　 　 　 　 　 　 　     2
　 　 　 〇 ●  　 　 　     3
　 　 　 ●  ●  ●  　 　     4
　 　 　 　 　 　 　 　     5
　 　 　 　 　 　 　 　     6
　 　 　 　 　 　 　 　     7


# 中略

終了 ●13 〇0

A  B  C  D  E  F  G  H  Index
-  -  -  -  -  -  -  -  -----
　 　 　 　 　 　 　 　     0
　 　 　 　 　 　 　 　     1
　 　 　 　 ●  　 　 　     2
　 　 　 ●  ●  ●  　 　     3
　 　 ●  ●  ●  ●  ●  　     4
　 　 　 ●  ●  ●  　 　     5
　 　 　 　 ●  　 　 　     6
　 　 　 　 　 　 　 　     7

>
```

## ソースコード

[GitHub](https://github.com/kakei-akihiko/pso/blob/master/Othello.ps1)
