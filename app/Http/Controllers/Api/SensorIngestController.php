<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\SensorData;

class SensorIngestController extends Controller
{
    // Menerima JSON dari ESP32 (MicroPython)
    // Body contoh: {"suhu": 26.5, "kelembapan": 71.2, "waktu": "2025-10-15T09:00:00Z", "id_petani": 1}
    public function store(Request $request)
    {
        $data = $request->validate([
            'suhu' => 'required|numeric',
            'kelembapan' => 'required|numeric',
            'waktu' => 'required|date',
            'id_petani' => 'required|exists:users,id',
        ]);

        $record = SensorData::create($data);

        return response()->json([
            'message' => 'Sensor data stored',
            'data' => $record,
        ], 201);
    }
}
