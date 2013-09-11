# Usage: Load the script in the config and on the partyline do: .chanset #channel +naalinlinkit

setudef flag naalinlinkit

bind pubm -|- "*" naalinlinkit::handler

namespace eval naalinlinkit {
proc handler {nick mask hand channel arguments} {

# Set desired filename here. It will be appended with year and .txt
set filenameheader "naalinlinkit"

set year [clock format [clock seconds] -gmt true -format %Y]
set dbfile "${filenameheader}${year}.txt"
if {![file exists $dbfile]} { set txtfile [open $dbfile w]; close $txtfile }
set x $year
while {[file exists "${filenameheader}${x}.txt"]} { incr x -1 }
set inception [expr $x + 1]

if {[channel get $channel naalinlinkit] && [onchan $nick $channel]} {
	foreach item [split $arguments] {
	if {[string match -nocase "http://?*" $item] || [string match -nocase "www.?*" $item] || [string match -nocase "https://?*" $item]} {
		for {set x $inception} {$x <= $year} {incr x} {
			set txtfile [open "${filenameheader}${x}.txt" r+]
			while {![eof $txtfile]} {
				set urlfound false 
	                        set processline [gets $txtfile]
				if {[naalinlinkit::apinahandler $item [lindex $processline 2]]} { set urlfound true }
				if {[naalinlinkit::imgurhandler $item [lindex $processline 2]]} { set urlfound true }
				if {[naalinlinkit::kuvatonhandler $item [lindex $processline 2]]} { set urlfound true }
				if {[naalinlinkit::youtubehandler $item [lindex $processline 2]]} { set urlfound true }
        	                if {[string match -nocase $item [lindex $processline 2]]} {set urlfound true}
				if {$urlfound} {naalinlinkit::output $channel $processline}
	               	        unset processline
			}
			if {$x == $year} {puts $txtfile "[clock seconds] $nick $item"}
			close $txtfile
		}
	}
	unset item }
} }

proc output {channel outputtime} {
putquick "PRIVMSG $channel :w, [clock format [lindex $outputtime 0] -gmt true -format "%D %H:%M"]"
}

proc apinahandler {url test} {
if {[lindex [split $url "/"] 2] == "apina.biz"} { set ying [regsub -all {[^0-9]} $url ""] }
if {[lindex [split $test "/"] 2] == "apina.biz"} { set yang [regsub -all {[^0-9]} $test ""] }
if {[lindex [split [lindex [split $url "/"] 2] "."] 2] == "apcdn"} { set ying [regsub -all {[^0-9]} [lindex [split $url "/"] end] ""] }
if {[lindex [split [lindex [split $test "/"] 2] "."] 2] == "apcdn"} { set yang [regsub -all {[^0-9]} [lindex [split $test "/"] end] ""] }
if {[info exists ying] && [info exists yang]} {
	if {[string match $ying $yang]} { return true } else {return false } } else { return false }
}

proc imgurhandler {url test} {
if {[lindex [split [lindex [split $url "//"] 2] .] end-1] == "imgur"} {set ying [lindex [split [lindex [split $url "/"] end] .] 0]}
if {[lindex [split [lindex [split $test "//"] 2] .] end-1] == "imgur"} {set yang [lindex [split [lindex [split $test "/"] end] .] 0]}
if {[info exists ying] && [info exists yang]} {
	if {[string match $ying $yang]} { return true } else { return false } } else { return false }
}

proc kuvatonhandler {url test} {
if {[lindex [split [lindex [split $url "//"] 2] .] end-1] == "kuvaton"} {set ying [lindex [split [lindex [split $url "/"] end] .] 0]}
if {[lindex [split [lindex [split $test "//"] 2] .] end-1] == "kuvaton"} {set yang [lindex [split [lindex [split $test "/"] end] .] 0]}
if {[info exists ying] && [info exists yang]} {
        if {[string match $ying $yang]} { return true } else { return false } } else { return false }
}

proc youtubehandler {url test} {
set urlfound false
if {[lindex [split [lindex [split $url "//"] 2] .] end-1] == "youtube"} {
        foreach item [split [lindex [split $url "/"] end] "&"] {
                if {[string match [lindex [split [lindex [split $item "="] 0] "?"] 0] watch]} {
                        set ying [lindex [split [lindex [split $item "="] 1] "?"] 0] } }
}
if {[lindex [split [lindex [split $test "//"] 2] .] end-1] == "youtube"} {
        foreach item [split [lindex [split $test "/"] end] "&"] {
                if {[string match [lindex [split [lindex [split $item "="] 0] "?"] 0] watch]} {
                        set yang [lindex [split [lindex [split $item "="] 1] "?"] 0] } }
}

if {[lindex [split [lindex [split $url "//"] 2] .] end-1] == "youtu"} { set ying [lindex [split $url "/"] end] }
if {[lindex [split [lindex [split $test "//"] 2] .] end-1] == "youtu"} { set yang [lindex [split $test "/"] end] }

if {[info exists ying] && [info exists yang]} {
        if {[string match $ying $yang]} {return true } else {return false} } else {return false }
}

}

putlog "Naalinlinkit V2.0 by T-101"
