import lol.pierrelasse.lua.*;
import lol.pierrelasse.lua.lib.javaccessor.*;
import net.bluept.scripting.Scripting;

import com.github.retrooper.packetevents.event.*;
import com.github.retrooper.packetevents.protocol.packettype.PacketType;

import java.util.Map;
import java.util.HashMap;

public class pierrelasse_lib_integration_packetevents_Listener implements PacketListener {
    public final PacketListenerCommon common;

    public LuaFunction packetReceive;
    public LuaFunction packetSend;

    public pierrelasse_lib_integration_packetevents_Listener(PacketListenerPriority priority) {
        common = asAbstract(priority);
    }

    @Override
    public void onPacketReceive(PacketReceiveEvent event) {
        if (packetReceive == null) return;
        try {
            packetReceive.call(JavaAccessor.lua(event));
        } catch (LuaError le) {
            Scripting.catchLast("packetevents receive", le);
        }
    }

    @Override
    public void onPacketSend(PacketSendEvent event) {
        if (packetSend == null) return;
        try {
            packetSend.call(JavaAccessor.lua(event));
        } catch (LuaError le) {
            Scripting.catchLast("packetevents send", le);
        }
    }
}
