immutable GdkRectangle
    x::Int32
    y::Int32
    width::Int32
    height::Int32
    GdkRectangle(x,y,w,h) = new(x,y,w,h)
end
make_gvalue(GdkRectangle, Ptr{GdkRectangle}, :boxed, (:gdk_rectangle,:libgdk))
convert(::Type{GdkRectangle}, rect::Ptr{GdkRectangle}) = unsafe_load(rect)

immutable GdkPoint
    x::Int32
    y::Int32
    GdkPoint(x,y) = new(x,y)
end
# GdkPoint is not a GBoxed type

gdk_window(w::GtkWidgetI) = ccall((:gtk_widget_get_window,libgtk),Ptr{Void},(Ptr{GObject},),w)

baremodule GdkKeySyms
  const VoidSymbol = 0xffffff
  const BackSpace = 0xff08
  const Tab = 0xff09
  const Linefeed = 0xff0a
  const Clear = 0xff0b
  const Return = 0xff0d
  const Pause = 0xff13
  const Scroll_Lock = 0xff14
  const Sys_Req = 0xff15
  const Escape = 0xff1b
  const Delete = 0xffff
  const Home = 0xff50
  const Left = 0xff51
  const Up = 0xff52
  const Right = 0xff53
  const Down = 0xff54
  const Page_Up = 0xff55
  const Next = 0xff56
  const Page_Down = 0xff56
  const End = 0xff57
  const Insert = 0xff63
  const Num_Lock = 0xff7f
  const F1 = 0xffbe
  const F2 = 0xffbf
  const F3 = 0xffc0
  const F4 = 0xffc1
  const F5 = 0xffc2
  const F6 = 0xffc3
  const F7 = 0xffc4
  const F8 = 0xffc5
  const F9 = 0xffc6
  const F10 = 0xffc7
  const F11 = 0xffc8
  const F12 = 0xffc9
  const Shift_L = 0xffe1
  const Shift_R = 0xffe2
  const Control_L = 0xffe3
  const Control_R = 0xffe4
  const Caps_Lock = 0xffe5
  const Shift_Lock = 0xffe6
  const Meta_L = 0xffe7
  const Meta_R = 0xffe8
  const Alt_L = 0xffe9
  const Alt_R = 0xffea
  const Super_L = 0xffeb
  const Super_R = 0xffec
  const Hyper_L = 0xffed
  const Hyper_R = 0xffee
end

abstract GdkEventI
make_gvalue(GdkEventI, Ptr{GdkEventI}, :boxed, (:gdk_event,:libgdk))
function convert(::Type{GdkEventI}, evt::Ptr{GdkEventI})
    e = unsafe_load(convert(Ptr{GdkEventAny},evt))
    if     e.event_type == GdkEventType.KEY_PRESS ||
           e.event_type == GdkEventType.KEY_RELEASE
        return unsafe_load(convert(Ptr{GdkEventKey},evt))
    elseif e.event_type == GdkEventType.BUTTON_PRESS ||
           e.event_type == GdkEventType.DOUBLE_BUTTON_PRESS ||
           e.event_type == GdkEventType.TRIPLE_BUTTON_PRESS ||
           e.event_type == GdkEventType.BUTTON_RELEASE
        return unsafe_load(convert(Ptr{GdkEventButton},evt))
    elseif e.event_type == GdkEventType.SCROLL
        return unsafe_load(convert(Ptr{GdkEventScroll},evt))
    elseif e.event_type == GdkEventType.MOTION_NOTIFY
        return unsafe_load(convert(Ptr{GdkEventMotion},evt))
    elseif e.event_type == GdkEventType.ENTER_NOTIFY ||
           e.event_type == GdkEventType.LEAVE_NOTIFY
        return unsafe_load(convert(Ptr{GdkEventCrossing},evt))
    else
        return unsafe_load(convert(Ptr{GdkEventAny},evt))
    end
end

immutable GdkEventAny <: GdkEventI
    event_type::Enum
    gdk_window::Ptr{Void}
    send_event::Int8
end

immutable GdkEventButton <: GdkEventI
    event_type::Enum
    gdk_window::Ptr{Void}
    send_event::Int8
    time::Uint32
    x::Float64
    y::Float64
    axes::Ptr{Float64}
    state::Uint32
    button::Uint32
    gdk_device::Ptr{Void}
    x_root::Float64
    y_root::Float64
end

immutable GdkEventScroll <: GdkEventI
    event_type::Enum
    gdk_window::Ptr{Void}
    send_event::Int8
    time::Uint32
    x::Float64
    y::Float64
    state::Uint32
    direction::Enum
    gdk_device::Ptr{Void}
    x_root::Float64
    y_root::Float64
    delta_x::Float64
    delta_y::Float64
end

immutable GdkEventKey <: GdkEventI
    event_type::Enum
    gdk_window::Ptr{Void}
    send_event::Int8
    time::Uint32
    state::Uint32
    keyval::Uint32
    length::Int32
    string::Ptr{Uint8}
    hardware_keycode::Uint16
    group::Uint8
    flags::Uint32
end

is_modifier(evt::GdkEventKey) = (evt.flags & 0x0001) > 0

immutable GdkEventMotion <: GdkEventI
  event_type::Enum
  gdk_window::Ptr{Void}
  send_event::Int8
  time::Uint32
  x::Float64
  y::Float64
  axes::Ptr{Float64}
  state::Uint32
  is_hint::Int16
  gdk_device::Ptr{Void}
  x_root::Float64
  y_root::Float64
end

immutable GdkEventCrossing <: GdkEventI
  event_type::Enum
  gdk_window::Ptr{Void}
  send_event::Int8
  gdk_subwindow::Ptr{Void}
  time::Uint32
  x::Float64
  y::Float64
  x_root::Float64
  y_root::Float64
  mode::Enum
  detail::Enum
  focus::Cint
  state::Uint32
end

keyval(name::String) =
  ccall((:gdk_keyval_from_name,libgdk),Cuint,(Ptr{Uint8},),bytestring(name))

