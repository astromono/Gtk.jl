macro gtktype(name)
    groups = split(string(name), r"(?=[A-Z])")
    symname = symbol(join([lowercase(s) for s in groups],"_"))
    :( @Gtype $(esc(name)) libgtk $(esc(symname)))
end
@gtktype GtkWidget
@gtktype GtkContainer
@gtktype GtkBin
@gtktype GtkDialog
@gtktype GtkMenuShell

convert(::Type{Ptr{GObjectI}},w::String) = convert(Ptr{GObjectI},GtkLabel(w))

destroy(w::GtkWidgetI) = ccall((:gtk_widget_destroy,libgtk), Void, (Ptr{GObjectI},), w)
parent(w::GtkWidgetI) = convert(GtkWidgetI, ccall((:gtk_widget_get_parent,libgtk), Ptr{GObjectI}, (Ptr{GObjectI},), w))
hasparent(w::GtkWidgetI) = ccall((:gtk_widget_get_parent,libgtk), Ptr{Void}, (Ptr{GObjectI},), w) != C_NULL
function toplevel(w::GtkWidgetI)
    p = convert(Ptr{GObjectI}, w)
    pp = p
    while pp != C_NULL
        p = pp
        pp = ccall((:gtk_widget_get_parent,libgtk), Ptr{GObjectI}, (Ptr{GObjectI},), p)
    end
    convert(GtkWidgetI, p)
end
function allocation(widget::Gtk.GtkWidgetI)
    allocation_ = Array(GdkRectangle)
    ccall((:gtk_widget_get_allocation,libgtk), Void, (Ptr{GObject},Ptr{GdkRectangle}), widget, allocation_)
    return allocation_[1]
end
if gtk_version > 3
    width(w::GtkWidgetI) = ccall((:gtk_widget_get_allocated_width,libgtk),Cint,(Ptr{GObjectI},),w)
    height(w::GtkWidgetI) = ccall((:gtk_widget_get_allocated_height,libgtk),Cint,(Ptr{GObjectI},),w)
    size(w::GtkWidgetI) = (width(w),height(w))
else
    width(w::GtkWidgetI) = allocation(w).width
    height(w::GtkWidgetI) = allocation(w).height
    size(w::GtkWidgetI) = (a=allocation(w);(a.width,a.height))
end

### Functions and methods common to all GtkWidget objects
#GtkAdjustment(lower,upper,value=lower,step_increment=0,page_increment=0,page_size=0) =
#    ccall((:gtk_adjustment_new,libgtk),Ptr{Void},
#        (Cdouble,Cdouble,Cdouble,Cdouble,Cdouble,Cdouble),
#        value, lower, upper, step_increment, page_increment, page_size)

visible(w::GtkWidgetI) = bool(ccall((:gtk_widget_get_visible,libgtk),Cint,(Ptr{GObjectI},),w))
visible(w::GtkWidgetI, state::Bool) = ccall((:gtk_widget_set_visible,libgtk),Void,(Ptr{GObjectI},Cint),w,state)
show(w::GtkWidgetI) = ccall((:gtk_widget_show,libgtk),Void,(Ptr{GObjectI},),w)
showall(w::GtkWidgetI) = ccall((:gtk_widget_show_all,libgtk),Void,(Ptr{GObjectI},),w)

# TODO Use Pango type PangoFontDescription once it is wrapped
modifyfont(w::GtkWidgetI, font_desc::Ptr{Void}) = 
   ccall((:gtk_widget_modify_font,libgtk),Void,(Ptr{GObjectI},Ptr{Void}),w,font_desc)

function getproperty{T}(w::GtkContainerI, name::Union(String,Symbol), child::GtkWidgetI, ::Type{T})
    v = gvalue(T)
    ccall((:gtk_container_child_get_property,libgtk), Void,
        (Ptr{GObject}, Ptr{GObject}, Ptr{Uint8}, Ptr{GValue}), w, child, bytestring(name), v)
    val = v[T]
    ccall((:g_value_unset,libgobject),Void,(Ptr{GValue},), v)
    return val
end

#property(w::GtkContainerI, value, child::GtkWidgetI, ::Type{T}) = error("missing Gtk property-name to set")
setproperty!{T}(w::GtkContainerI, name::Union(String,Symbol), child::GtkWidgetI, ::Type{T}, value) = setproperty!(w, name, child, convert(T,value))
function setproperty!(w::GtkContainerI, name::Union(String,Symbol), child::GtkWidgetI, value)
    ccall((:gtk_container_child_set_property,libgtk), Void,
        (Ptr{GObject}, Ptr{GObject}, Ptr{Uint8}, Ptr{GValue}), w, child, bytestring(name), gvalue(value))
    w
end

@deprecate getindex(w::GtkContainerI, child::GtkWidgetI, name::Union(String,Symbol), T::Type) getproperty(w,name,child,T)
@deprecate setindex!(w::GtkContainerI, value, child::GtkWidgetI, name::Union(String,Symbol), T::Type) setproperty!(w,name,child,T,value)
@deprecate setindex!(w::GtkContainerI, value, child::GtkWidgetI, name::Union(String,Symbol)) setproperty!(w,name,child,value)

@gtktype GtkAccelGroup
GtkAccelGroup() = GtkAccelGroup(
    ccall((:gtk_accel_group_new,libgtk),Ptr{GObject},()))

function push!(w::GtkWidgetI, accel_signal::String, accel_group::GtkAccelGroup,
               accel_key::Integer, accel_mods::Integer, accel_flags::Integer)
    ccall((:gtk_widget_add_accelerator,libgtk), Void,
         (Ptr{GObject}, Ptr{Uint8}, Ptr{GObject}, Cuint, Cint, Cint), 
          w, bytestring(accel_signal),accel_group, accel_key, accel_mods, accel_flags)
    w
end  
      
