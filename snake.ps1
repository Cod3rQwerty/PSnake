$width = [Console]::WindowWidth - 6
$height = [Console]::WindowHeight - 6

[Console]::BufferWidth = $width + 10
[Console]::BufferHeight = $height + 10

# GAMEPLAY VARIABLES
$normal_speed = 300
$boost_speed = 50

# INITIALISE SNAKE

$snake = [System.Collections.Generic.List[hashtable]]::new()

$midX = [int][math]::Floor($width / 2)
$midY = [int][math]::Floor($height / 2)

$snake.Add(@{ X = $midX - 2; Y = $midY })
$snake.Add(@{ X = $midX - 1; Y = $midY })
$snake.Add(@{ X = $midX; Y = $midY })

# INITIALISE TARGET POSITION
$target_pos = @{X = [int][math]::Floor($midX + $width / 4) ; Y = $midY }

[Console]::CursorVisible = $false

function write-borders {
    # Top
    Write-Host ("+" + ("-" * ($width + 2)) + "+")

    # Sides
    for ($i = 0; $i -lt $height; $i++) {
        Write-Host ("|" + (" " * $width) + "|")
    }

    # Bottom
    Write-Host ("+" + ("-" * ($width + 2)) + "+")
}

function write-snake_part {
    param (
        [int] $x,
        [int] $y,
        [bool] $boosting
    )
    [Console]::SetCursorPosition($x, $y)
    if (-not $boosting){
        Write-Host "#" -ForegroundColor Green
    }
    else {
        Write-Host "#" -ForegroundColor Red
    }
}

function clear-screen_part {
    param (
        [int] $x,
        [int] $y
    )
    [Console]::SetCursorPosition($x, $y)
    Write-Host " " -NoNewline
}

function write-snake {
    param (
        [System.Collections.Generic.List[hashtable]] $snakeList,
        [bool] $boosting
    )
    
    foreach ($snake_part in $snakeList) {
        write-snake_part $snake_part.X $snake_part.Y $boosting
    }
}

function write-target {
    param (
        [int] $x,
        [int] $y
    )

    [Console]::SetCursorPosition($x, $y)
    Write-Host "X" -ForegroundColor White
}

function get-next_head_position {
    param (
        [int] $dx,
        [int] $dy,
        [hashtable] $head_coords,
        [hashtable] $previous_head_coords
    )

    $new_coords = @{X = $head_coords.X + $dx; Y = $head_coords.Y + $dy }

    return $new_coords
}

function is-coord_in_snake {
    param (
        [hashtable] $coord,
        [System.Collections.Generic.List[hashtable]] $snake
    )
    foreach ($snake_part in $snake) {
        if (($snake_part.X -eq $coord.X) -and ($snake_part.Y -eq $coord.Y)) {
            return $true
        }
    }

    return $false
}

function get-new_target_pos {
    param (
        [System.Collections.Generic.List[hashtable]] $snake
    )
    while ($true) {
        $new_pos = @{X = Get-Random -Minimum 1 -Maximum ($width - 1);
                     Y = Get-Random -Minimum 1 -Maximum ($height - 1);
        }

        if (-not (is-coord_in_snake $new_pos $snake)) {
            return $new_pos
        }
    }
}

Clear-Host
write-borders
write-snake $snake $false
write-target $target_pos.X $target_pos.Y


$direction_x = 1  # (1 = Right, -1 = Left)
$direction_y = 0  # (1 = Down, -1 = Up)
$gameOver = $false
$boosting = $false
$score = 0

while (-not $gameOver) {

    $target_collected = $false
    
    if ([Console]::KeyAvailable) {
        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow" { if ($direction_y -eq 0) { $direction_x = 0; $direction_y = -1 } }
            "DownArrow" { if ($direction_y -eq 0) { $direction_x = 0; $direction_y = 1 } }
            "LeftArrow" { if ($direction_x -eq 0) { $direction_x = -1; $direction_y = 0 } }
            "RightArrow" { if ($direction_x -eq 0) { $direction_x = 1; $direction_y = 0 } }
            "Spacebar" {if ($boosting) {$boosting = $false} else {$boosting = $true}}
            "Escape" { $gameOver = $true }
        }
    }
    

    $newHead = get-next_head_position $direction_x $direction_y $snake[-1] $snake[-2]

    if (($target_pos.X -eq $newHead.X) -and ($target_pos.Y -eq $newHead.Y)){
        $target_collected = $true
        $score += 1
        $target_pos = get-new_target_pos $snake
        write-target $target_pos.X $target_pos.Y
    }
    if (-not $target_collected){
        clear-screen_part $snake[0].X $snake[0].Y
        $snake.RemoveAt(0)
    }

    if (is-coord_in_snake $newHead $snake) {
        $gameOver = $true
    }
    if (($newHead.X -in @(0, $width)) -or ($newHead.Y -in @(0, $height))) {
        $gameOver = $true
    }

    $snake.Add($newHead)

    write-snake $snake $boosting

    if ($boosting) {
        Start-Sleep -Milliseconds $boost_speed
    }
    else {
        Start-Sleep -Milliseconds $normal_speed
    }
}

[Console]::SetCursorPosition(0, $height + 4)
[Console]::CursorVisible = $true

Write-Host "Game over"
Write-Host ("You scored " + [string]$score + " points!")