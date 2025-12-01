@extends('layouts.app')

@section('title', 'Dashboard')

@section('content')
<div class="max-w-4xl mx-auto">
    <div class="bg-white dark:bg-[#161615] shadow-[inset_0px_0px_0px_1px_rgba(26,26,0,0.16)] dark:shadow-[inset_0px_0px_0px_1px_#fffaed2d] rounded-lg p-8">
        <h1 class="text-3xl font-semibold mb-4">Welcome, {{ Auth::user()->name }}!</h1>
        <p class="text-[#706f6c] dark:text-[#A1A09A] mb-8">You are successfully logged in to your account.</p>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="p-6 border border-[#e3e3e0] dark:border-[#3E3E3A] rounded-lg">
                <h2 class="text-lg font-semibold mb-2">Account Information</h2>
                <div class="space-y-2 text-sm">
                    <p><span class="text-[#706f6c] dark:text-[#A1A09A]">Name:</span> {{ Auth::user()->name }}</p>
                    <p><span class="text-[#706f6c] dark:text-[#A1A09A]">Email:</span> {{ Auth::user()->email }}</p>
                </div>
            </div>

            <div class="p-6 border border-[#e3e3e0] dark:border-[#3E3E3A] rounded-lg">
                <h2 class="text-lg font-semibold mb-2">Quick Actions</h2>
                <div class="space-y-2">
                    <form method="POST" action="{{ route('logout') }}" class="inline">
                        @csrf
                        <button type="submit" class="text-sm text-[#f53003] dark:text-[#FF4433] hover:underline">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

