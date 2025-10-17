<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\IotData;

class IoTController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        if ($user->role === 'admin') {
            $data = IotData::latest('updated_at')->paginate(50);
        } else {
            $data = IotData::where('user_id', $user->id)->latest('updated_at')->paginate(50);
        }
        return response()->json($data);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'temperature' => 'required|numeric',
            'humidity' => 'required|numeric',
            'soil_moisture' => 'required|numeric',
            'updated_at' => 'nullable|date',
            'user_id' => 'nullable|exists:users,id',
        ]);

        $user = $request->user();
        $ownerId = $data['user_id'] ?? $user->id;

        if ($user->role === 'petani' && $ownerId !== $user->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $record = IotData::create([
            'user_id' => $ownerId,
            'temperature' => $data['temperature'],
            'humidity' => $data['humidity'],
            'soil_moisture' => $data['soil_moisture'],
            'updated_at' => $data['updated_at'] ?? now(),
        ]);

        return response()->json($record, 201);
    }
}
