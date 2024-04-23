package se.chalmers.log4shell;

import java.io.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@WebServlet(name = "log4ShellDemo", value = "/login")
public class Log4ShellDemo extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(Log4ShellDemo.class);

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        String userName = req.getParameter("username");
        String password = req.getParameter("password");

        PrintWriter out = resp.getWriter();
        if(userName == null || password == null){
            out.println("Please enter username or password");
        }else if(userName.equals("user") && password.equals("pwd123")){
            out.println("Login Successful");
        }else{
            logger.error("The username or password is invalid");
            logger.error(userName);
            out.println("Login Unsuccessful");
        }
    }
}