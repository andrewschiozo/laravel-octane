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
        'users' => $users,
        'nil' => null
    ]);
});

Route::get('/info', function () {
    return response()->json([
        'php_version' => phpversion(),
        'laravel_version' => app()->version(),
        'environment' => app()->environment(),
        'debug' => config('app.debug'),
        'directory' => base_path(),
    ]);
});
