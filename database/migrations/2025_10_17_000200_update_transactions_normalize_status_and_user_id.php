<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            if (Schema::hasColumn('transactions', 'buyer_id') && !Schema::hasColumn('transactions', 'user_id')) {
                $table->renameColumn('buyer_id', 'user_id');
            }
        });

        // Normalize status to simple string with allowed values handled at app layer
        Schema::table('transactions', function (Blueprint $table) {
            if (Schema::hasColumn('transactions', 'status')) {
                $table->string('status', 32)->default('pending')->change();
            }
        });

        // Optional: map old statuses
        try {
            DB::table('transactions')->whereIn('status', ['paid','shipped','completed','canceled'])->update(['status' => 'processed']);
        } catch (\Throwable $e) {
        }
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            if (Schema::hasColumn('transactions', 'user_id') && !Schema::hasColumn('transactions', 'buyer_id')) {
                $table->renameColumn('user_id', 'buyer_id');
            }
            if (Schema::hasColumn('transactions', 'status')) {
                // best-effort revert to pending
                $table->enum('status', ['pending','paid','shipped','completed','canceled'])->default('pending')->change();
            }
        });
    }
};
