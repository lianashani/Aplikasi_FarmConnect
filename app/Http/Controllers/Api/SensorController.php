<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\SensorReading;

class SensorController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $items = SensorReading::where('user_id', $user->id)
            ->latest('recorded_at')
            ->paginate(50);

        return response()->json([
            'data' => $items->items(),
            'meta' => [
                'current_page' => $items->currentPage(),
                'last_page' => $items->lastPage(),
                'total' => $items->total(),
            ],
        ]);
    }

    public function latest(Request $request)
    {
        $user = $request->user();
        $latest = SensorReading::where('user_id', $user->id)
            ->latest('recorded_at')
            ->first();
        return response()->json($latest);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        $data = $request->validate([
            'temperature' => 'required|numeric',
            'soil_moisture' => 'required|numeric',
            'plant_status' => 'nullable|string|max:100',
            'recorded_at' => 'nullable|date',
        ]);

        $reading = SensorReading::create([
            'user_id' => $user->id,
            'temperature' => $data['temperature'],
            'soil_moisture' => $data['soil_moisture'],
            'plant_status' => $data['plant_status'] ?? null,
            'recorded_at' => $data['recorded_at'] ?? now(),
        ]);

        return response()->json($reading, 201);
    }
}
