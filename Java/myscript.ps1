$searchString = "../typora-user-images/img/img/"
$replaceString = "../img/"
$files = Get-ChildItem -Path "C:\Users\Liu\Desktop\info\LiuLearningNotes\Java" -Filter *.md

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8
    $modifiedContent = $content | ForEach-Object {
        $_ -replace $searchString, $replaceString
    }
    Set-Content -Path $file.FullName -Value $modifiedContent -Encoding UTF8
}
