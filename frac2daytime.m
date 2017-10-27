function outstr=frac2daytime(time)
    hour=time.*24;
    hh=fix(hour);
    minute=(hour-hh).*60;
    mm=fix(minute);
    seconds=(minute-mm).*60;
    ss=fix(seconds);
    outstr=datetime(0,0,0,hh,mm,ss,'Format','HH:mm:ss');
end