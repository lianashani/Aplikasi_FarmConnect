<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use App\Models\User;
use App\Models\Product;
use App\Models\IotData;

class DemoSeeder extends Seeder
{
    public function run(): void
    {
        // Create demo farmer (petani) user if not exists
        $attrs = [
            'name' => 'Petani Demo',
            'password' => Hash::make('password'),
        ];
        if (Schema::hasColumn('users', 'role')) {
            $attrs['role'] = 'petani';
            if (Schema::hasColumn('users', 'is_active')) {
                $attrs['is_active'] = true;
            }
        }
        $user = User::firstOrCreate(
            ['email' => 'petani@example.com'],
            $attrs
        );

        // Create demo buyer (pembeli) user if not exists
        $buyerAttrs = [
            'name' => 'Pembeli Demo',
            'password' => Hash::make('password'),
        ];
        if (Schema::hasColumn('users', 'role')) {
            $buyerAttrs['role'] = 'pembeli';
            if (Schema::hasColumn('users', 'is_active')) {
                $buyerAttrs['is_active'] = true;
            }
        }
        $buyer = User::firstOrCreate(
            ['email' => 'pembeli@example.com'],
            $buyerAttrs
        );

        // Create some products if table empty
        if (Product::count() === 0) {
            Product::create([
                'user_id' => $user->id,
                'name' => 'Tomat Segar',
                'description' => 'Tomat merah segar dari kebun',
                'price' => 12000,
                'stock' => 50,
                'image_url' => null,
            ]);
            Product::create([
                'user_id' => $user->id,
                'name' => 'Cabai Merah',
                'description' => 'Cabai merah pedas',
                'price' => 25000,
                'stock' => 30,
                'image_url' => null,
            ]);
            Product::create([
                'user_id' => $user->id,
                'name' => 'Bayam Organik',
                'description' => 'Sayur hijau organik',
                'price' => 8000,
                'stock' => 100,
                'image_url' => null,
            ]);
        }

        // IoT dummy rows
        if (class_exists(IotData::class)) {
            IotData::create([
                'user_id' => $user->id,
                'temperature' => 26.5,
                'humidity' => 70.2,
                'soil_moisture' => 55.1,
                'updated_at' => now()->subHours(3),
            ]);
            IotData::create([
                'user_id' => $user->id,
                'temperature' => 27.1,
                'humidity' => 68.4,
                'soil_moisture' => 52.7,
                'updated_at' => now()->subHour(),
            ]);
        }
    }
}
