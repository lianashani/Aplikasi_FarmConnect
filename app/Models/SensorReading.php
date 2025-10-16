<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SensorReading extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'temperature', 'soil_moisture', 'plant_status', 'recorded_at'
    ];

    protected $casts = [
        'recorded_at' => 'datetime',
        'temperature' => 'float',
        'soil_moisture' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
