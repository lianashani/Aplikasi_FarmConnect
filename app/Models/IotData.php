<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class IotData extends Model
{
    use HasFactory;

    protected $table = 'iot_data';

    protected $fillable = [
        'user_id', 'temperature', 'humidity', 'soil_moisture', 'updated_at'
    ];

    public $timestamps = false; // we manage updated_at per spec

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
