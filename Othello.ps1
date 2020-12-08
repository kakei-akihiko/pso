
$rows = 0..7 | ForEach-Object {
  $rowIndex = $_
  $cells = 'A'..'H' | ForEach-Object {
    $cell = New-Object PSObject
    $cell | Add-Member NoteProperty Column $_
    $cell | Add-Member NoteProperty Row $rowIndex
    if ($rowIndex -eq 3 -and $_ -eq 'D') {
      $value = '〇'
    } elseif ($rowIndex -eq 3 -and $_ -eq 'E') {
      $value = '●'
    } elseif ($rowIndex -eq 4 -and $_ -eq 'D') {
      $value = '●'
    } elseif ($rowIndex -eq 4 -and $_ -eq 'E') {
      $value = '〇'
    } else {
      $value = '　'
    }
    $cell | Add-Member NoteProperty Value $value
    $cell
  }
  $row = New-Object PSObject
  $row | Add-Member Cells $cells
  $row | Add-Member Index $rowIndex
  $row
}

$board = New-Object PSObject

$board | Add-Member NoteProperty Next '●'

$board | Add-Member ScriptProperty Other {
  if ($this.Next -eq '●') {
    return '〇'
  } elseif ($this.Next -eq '〇') {
    return '●'
  }
}

$board | Add-Member NoteProperty Rows $rows

$board | Add-Member ScriptMethod GetCellsByCellAndVector {
  param([int] $columnIndex, [int] $rowIndex, $vector)

  return 1..8 | ForEach-Object {
    $x = $columnIndex + $vector.X * $_
    $y = $rowIndex + $vector.Y * $_
    if ($x -lt 0 -or $x -ge 8 -or $y -lt 0 -or $y -ge 8) {
      return $null
    }
    return $this.Rows[$y].Cells[$x]
  }
}

$board | Add-Member ScriptMethod CanPlaceByCells {
  param($next, $cells)

  if ($cells[0] -eq $null -or $cells[0].Value -ne $this.Other) {
    return $false
  }

  for ($i = 1; $i -lt 8; $i++) {
    if ($cells[$i] -eq $null -or $cells[$i].Value -eq '　') {
      return $false
    } elseif ($cells[$i].Value -eq $next) {
      return $true
    }
  }
  return $false
}

$board | Add-Member ScriptMethod CanPlace {
  param([int] $columnIndex, [int] $rowIndex)

  if ($columnIndex -lt 0 -or $columnIndex -ge 8) {
    return $false
  } elseif ($rowIndex -lt 0 -or $rowIndex -ge 8) {
    return $false
  } elseif ($this.Rows[$rowIndex].Cells[$columnIndex].Value -ne '　') {
    return $false
  }

  for ($i = 0; $i -lt $this.Vectors.Length; $i++) {
    $cells = $this.GetCellsByCellAndVector($columnIndex, $rowIndex, $this.Vectors[$i])
    $result = $this.CanPlaceByCells($this.Next, $cells)
    if ($result) {
      return $true
    }
  }
  return $false
}

$board | Add-Member ScriptMethod IsPassNeeded {
  for($y = 0; $y -lt 8; $y++) {
    for($x = 0; $x -lt 8; $x++) {
      if ($this.CanPlace($x, $y)) {
        return $false
      }
    }
  }
  return $true
}

$board | Add-Member ScriptMethod Set {
  param([string] $positionString)

  $columnIndex = 'ABCDEFGH'.IndexOf($positionString[0])
  $rowIndex    = '01234567'.IndexOf($positionString[1])

  if ($this.CanPlace($columnIndex, $rowIndex) -eq $false) {
    Write-Host -ForegroundColor red ここには置けません。次は $this.Next
    return
  }

  $other = $this.Other
  $found = $false

  for ($i = 0; $i -lt $this.Vectors.Length; $i++) {
    $cells = $this.GetCellsByCellAndVector($columnIndex, $rowIndex, $this.Vectors[$i])
    $canPlace = $this.CanPlaceByCells($this.Next, $cells)
    if ($canPlace) {
      $this.Rows[$rowIndex].Cells[$columnIndex].Value = $this.Next
      for ($c = 0; $c -lt $cells.Length; $c++) {
        $cell = $cells[$c]
        if ($cell -eq $null -or $cell.Value -ne $other) {
          break
        }
        $cell.Value = $this.Next
        $found = $true
      }
    }
  }
  if ($found) {
    $lastPlaced = $this.Next
    $this.Next = $this.Other

    if ($this.IsPassNeeded()) {
      $lastPassed = $this.Next
      $this.Next = $this.other

      if ($this.IsPassNeeded()) {
        $cells = $this.Rows | ForEach-Object {$_.Cells}
        $player1st = ($cells | Where-Object {$_.Value -eq '●'}).Count
        $player2nd = ($cells | Where-Object {$_.Value -eq '〇'}).Count
        Write-Host 終了 ●$player1st 〇$player2nd
        $this.Show()
        return
      }
      Write-Host ('{0}ぱパスです。次は{1}' -f $lastPassed,$this.Next)
      $this.Show()

    } else {
      Write-Host ('{0}を置きました。次は{1}' -f $lastPlaced,$this.Next)
      $this.Next = $other
      $this.Show()
    }
  } else {
    Write-Host -ForegroundColor red ここには置けません。次は $this.Next
  }
}

$board | Add-Member NoteProperty Vectors @(
  @{X=-1; Y=-1}, @{X= 0; Y=-1}, @{X= 1; Y=-1},
  @{X=-1; Y= 0},                @{X= 1; Y= 0},
  @{X=-1; Y= 1}, @{X= 0; Y= 1}, @{X= 1; Y= 1}
)

$board | Add-Member ScriptMethod Show {
  $this.Rows | ForEach-Object {
    $row = $_
    $result = New-Object PSObject
    0..7 | ForEach-Object {
      $columnName = [char]([int]('A'[0]) + $_)
      $value = $row.Cells[$_].Value
      $result | Add-Member NoteProperty $columnName $value
    }
    $result | Add-Member NoteProperty Index $row.Index
    $result
  } | Format-Table
}

$board
