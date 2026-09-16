<?php

use App\Models\User;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'message' => 'Hello World',
        'deploy'  => 'Ok',
        'timestamp' => now()->toIso8601String()
    ]);
});

Route::get('/home', function () {
    return response()->json([
        'foo' => 'bar'
    ]);
});

Route::get('/users', function () {
    $users = User::all();
    return response()->json([
        'users' => $users
    ]);
});
