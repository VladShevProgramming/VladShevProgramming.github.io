$hit_count = @file_get_contents('count.txt');
$hit_count++;
@file_put_contents('count.txt', $hit_count);

header('Location: http://vladshevprogramming.github.io/lox/template.loxmod');