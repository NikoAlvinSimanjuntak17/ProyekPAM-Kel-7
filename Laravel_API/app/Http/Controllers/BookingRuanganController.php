<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BookingRuangan;
use App\Models\Ruangan;
use Illuminate\Support\Facades\Auth;

class BookingRuanganController extends Controller
{
    public function index()
    {
        // Fetch all bookings for the authenticated user
        $bookings = BookingRuangan::where('user_id', Auth::id())->get();

        return view('bookings.index', compact('bookings'));
    }

    public function create()
    {
        // Fetch all available rooms
        $rooms = Ruangan::all();

        return view('bookings.create', compact('rooms'));
    }

    public function store(Request $request)
    {
        // Validate the request
        $request->validate([
            'reason' => 'required|string',
            'room_id' => 'required|exists:ruangan,id',
            'start_time' => 'required|date',
            'end_time' => 'required|date|after:start_time',
        ]);

        // Check if the room is available for the specified time range
        $isRoomAvailable = BookingRuangan::where('room_id', $request->room_id)
            ->where(function ($query) use ($request) {
                $query->whereBetween('start_time', [$request->start_time, $request->end_time])
                    ->orWhereBetween('end_time', [$request->start_time, $request->end_time]);
            })
            ->doesntExist();

        if (!$isRoomAvailable) {
            return redirect()->route('bookings.create')->with('error', 'The room is not available for the specified time range.');
        }

        // Create a new booking
        BookingRuangan::create([
            'reason' => $request->reason,
            'user_id' => Auth::id(),
            'room_id' => $request->room_id,
            'start_time' => $request->start_time,
            'end_time' => $request->end_time,
        ]);

        return redirect()->route('bookings.index')->with('success', 'Booking created successfully.');
    }
}