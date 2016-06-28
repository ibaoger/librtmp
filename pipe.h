/** This file is part of the Mingw32 package.
*  unistd.h maps     (roughly) to io.h
*/
#ifndef _WIN32_PIPE_H
#define _WIN32_PIPE_H

#ifdef _WIN32
#include <stdio.h>
#include <winsock2.h>
#include <errno.h>
#endif // _WIN32

#ifdef __cplusplus
extern "C"
{
#endif


    int pipe(SOCKET handles[2]);
    int piperead(SOCKET s, void* buf, int len);
    int pipewrite(SOCKET s, const char * buf, int len);


    static int pipe(SOCKET handles[2])
    {
        SOCKET s;
        struct sockaddr_in serv_addr;
        int len = sizeof(serv_addr);

        handles[0] = handles[1] = INVALID_SOCKET;

        if ((s = socket(AF_INET, SOCK_STREAM, 0)) == INVALID_SOCKET)
        {
            printf("win32pipe failed to create socket: %ui", WSAGetLastError());
            return -1;
        }

        memset(&serv_addr, 0, sizeof(serv_addr));
        serv_addr.sin_family = AF_INET;
        serv_addr.sin_port = htons(0);
        serv_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
        if (bind(s, (SOCKADDR *)& serv_addr, len) == SOCKET_ERROR)
        {
            printf("win32pipe failed to bind: %ui", WSAGetLastError());
            closesocket(s);
            return -1;
        }
        if (listen(s, 1) == SOCKET_ERROR)
        {
            printf("event", "win32pipe failed to listen: %ui", WSAGetLastError());
            closesocket(s);
            return -1;
        }
        if (getsockname(s, (SOCKADDR *)& serv_addr, &len) == SOCKET_ERROR)
        {
            printf("win32pipe failed to getsockname: %ui", WSAGetLastError());
            closesocket(s);
            return -1;
        }
        if ((handles[1] = socket(PF_INET, SOCK_STREAM, 0)) == INVALID_SOCKET)
        {
            printf("win32pipe failed to create socket 2: %ui", WSAGetLastError());
            closesocket(s);
            return -1;
        }

        if (connect(handles[1], (SOCKADDR *)& serv_addr, len) == SOCKET_ERROR)
        {
            printf("win32pipe failed to connect socket: %ui", WSAGetLastError());
            closesocket(s);
            return -1;
        }
        if ((handles[0] = accept(s, (SOCKADDR *)& serv_addr, &len)) == INVALID_SOCKET)
        {
            printf("win32pipe failed to accept socket: %ui", WSAGetLastError());
            closesocket(handles[1]);
            handles[1] = INVALID_SOCKET;
            closesocket(s);
            return -1;
        }
        closesocket(s);
        return 0;
    }

    static int piperead(SOCKET s, void* buf, int len)
    {
        int ret = recv(s, buf, len, 0);

        if (ret < 0) {
            const int werror = WSAGetLastError();
            switch (werror) {
                /* simplified error mapping (not valid for connect) */
            case WSAEWOULDBLOCK:
                errno = EAGAIN;
                break;
            case WSAECONNRESET:
                /* EOF on the pipe! (win32 socket based implementation) */
                ret = 0;
                /* fall through */
            default:
                errno = werror;
                break;
            }
        }
        else
            errno = 0;
        return ret;
    }

    static int pipewrite(SOCKET s, const char * buf, int len)
    {
        return send(s, buf, len, 0);
    }


#ifdef __cplusplus
};
#endif

#endif /* _WIN32_PIPE_H */
