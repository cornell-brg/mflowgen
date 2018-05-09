#=========================================================================
# FL model of Blocking Cache
#=========================================================================
# A function level cache model which only passes cache requests and
# responses to the memory.

from pymtl      import *
from pclib.ifcs import InValRdyBundle, OutValRdyBundle

# BRGTC2 custom MemMsg modified for RISC-V 32

from ifcs import MemReqMsg4B, MemRespMsg4B
from ifcs import MemReqMsg16B, MemRespMsg16B
from ifcs import MemReqMsg, MemRespMsg

class BlockingCacheWideAccessFL( Model ):

  def __init__( s, size = 256, nbanks = 0 ):

    #---------------------------------------------------------------------
    # Interface
    #---------------------------------------------------------------------

    # Proc <-> Cache

    s.cachereq  = InValRdyBundle ( MemReqMsg16B  )
    s.cacheresp = OutValRdyBundle( MemRespMsg16B )

    # Cache <-> Mem

    s.memreq    = OutValRdyBundle( MemReqMsg16B  )
    s.memresp   = InValRdyBundle ( MemRespMsg16B )

    #---------------------------------------------------------------------
    # Control
    #---------------------------------------------------------------------

    # pass through val/rdy signals

    s.connect( s.cachereq.val, s.memreq.val )
    s.connect( s.cachereq.rdy, s.memreq.rdy )

    s.connect( s.memresp.val, s.cacheresp.val )
    s.connect( s.memresp.rdy, s.cacheresp.rdy )

    #---------------------------------------------------------------------
    # Datapath
    #---------------------------------------------------------------------

    @s.combinational
    def logic():

      # Pass through requests: just copy all of the fields over, except
      # we zero-extend the data field (or sign-extend if it is a signed
      # AMO operation).

      len_ = s.cachereq.msg.len

      if s.cachereq.msg.type_ == MemReqMsg.TYPE_WRITE_INIT:
        s.memreq.msg.type_ = MemReqMsg.TYPE_WRITE
      else:
        s.memreq.msg.type_ = s.cachereq.msg.type_

      s.memreq.msg.opaque  = s.cachereq.msg.opaque
      s.memreq.msg.addr    = s.cachereq.msg.addr
      s.memreq.msg.len     = len_

      if ( s.cachereq.msg.type_ == MemReqMsg.TYPE_AMO_MIN or
           s.cachereq.msg.type_ == MemReqMsg.TYPE_AMO_MAX ):
        s.memreq.msg.data    = sext( s.cachereq.msg.data, 128 )
      else:
        s.memreq.msg.data    = zext( s.cachereq.msg.data, 128 )

      # Pass through responses: just copy all of the fields over, except
      # we truncate the data field.

      len_ = s.memresp.msg.len
      #if len_ == 4:
      #  len_ = 0

      s.cacheresp.msg.type_  = s.memresp.msg.type_
      s.cacheresp.msg.opaque = s.memresp.msg.opaque
      s.cacheresp.msg.test   = 0                        # "miss"
      s.cacheresp.msg.len    = len_
      s.cacheresp.msg.data   = s.memresp.msg.data

  def line_trace(s):
    return "(forw)"