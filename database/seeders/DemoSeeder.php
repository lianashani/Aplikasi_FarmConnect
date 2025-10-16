<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use App\Models\User;
use App\Models\Product;

class DemoSeeder extends Seeder
{
    public function run(): void
    {
        // Create demo farmer user if not exists
        $attrs = [
            'name' => 'Petani Demo',
            'password' => Hash::make('password'),
        ];
        if (Schema::hasColumn('users', 'role')) {
            $attrs['role'] = 'farmer';
        }
        $user = User::firstOrCreate(
            ['email' => 'petani@example.com'],
            $attrs
        );

        // Create demo buyer user if not exists
        $buyerAttrs = [
            'name' => 'Pembeli Demo',
            'password' => Hash::make('password'),
        ];
        if (Schema::hasColumn('users', 'role')) {
            $buyerAttrs['role'] = 'buyer';
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
    }
}
