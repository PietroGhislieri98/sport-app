<?php

use Illuminate\Support\Facades\Route;
use Symfony\Component\HttpKernel\Exception\HttpException;

Route::get('/', function () {
    throw new HttpException(500, 'Not Authorized');
});
