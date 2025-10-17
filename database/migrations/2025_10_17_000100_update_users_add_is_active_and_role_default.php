<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('role');
            }
            if (!Schema::hasColumn('users', 'role')) {
                $table->string('role')->default('pembeli')->after('password');
            } else {
                $table->string('role')->default('pembeli')->change();
            }
        });
        // Normalize existing role values from 'buyer' to 'pembeli'
        try {
            DB::table('users')->where('role', 'buyer')->update(['role' => 'pembeli']);
        } catch (\Throwable $e) {
            // ignore if table not yet migrated
        }
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'is_active')) {
                $table->dropColumn('is_active');
            }
            // revert default role to 'buyer' if needed
            if (Schema::hasColumn('users', 'role')) {
                $table->string('role')->default('buyer')->change();
            }
        });
    }
};
