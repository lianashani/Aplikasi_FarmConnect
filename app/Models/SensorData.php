<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SensorData extends Model
{
    use HasFactory;

    protected $table = 'sensor_data';

    protected $fillable = [
        'suhu',
        'kelembapan',
        'waktu',
        'id_petani',
    ];

    protected $casts = [
        'suhu' => 'float',
        'kelembapan' => 'float',
        'waktu' => 'datetime',
    ];

    public function petani()
    {
        return $this->belongsTo(User::class, 'id_petani');
    }
}
