<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'message' => 'Hello World',
        'timestamp' => now()->toIso8601String()
    ]);
});

Route::get('/home', function () {
    return response()->json([
        'foo' => 'bar'
    ]);
});
