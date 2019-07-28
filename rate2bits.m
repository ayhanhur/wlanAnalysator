function signalBits=rate2bits(rateMBits)

switch rateMBits
    case 6
        signalBits = [1 1 0 1];
    case 9
        signalBits = [1 1 1 1];
    case 12
        signalBits = [0 1 0 1];
    case 18
        signalBits = [0 1 1 1];
    case 24
        signalBits = [1 0 0 1];
    case 36
        signalBits = [1 0 1 1];
    case 48
        signalBits = [0 0 0 1];
    case 54
        signalBits = [0 0 1 1];
    otherwise
        error('illegal datarate')
end