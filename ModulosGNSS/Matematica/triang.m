function h = triang(t)

    h = (t+1).*((-1 <= t) & (t < 0)) + (-t+1).*((0 <= t) & (t <= 1));

end