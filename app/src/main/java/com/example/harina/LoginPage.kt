package com.example.harina

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.harina.data.UserDataBase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class LoginPage : AppCompatActivity() {

    private lateinit var Db: UserDataBase
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_login_page)

        var LoginButton = findViewById<Button>(R.id.LogInBtn)
        var LoginBackButton = findViewById<Button>(R.id.LoginBackBtn)
        var LoginUsername = findViewById<EditText>(R.id.LogInUsername)
        var LoginPassword = findViewById<EditText>(R.id.LogInPassword)


        Db = UserDataBase.getDatabase(this)

        LoginButton.setOnClickListener {
            val username = LoginUsername.text.toString()
            val password = LoginPassword.text.toString()

            CoroutineScope(Dispatchers.IO).launch {
                val loggedInUser = Db.userDao().login(username, password)
                runOnUiThread {
                    if (loggedInUser != null) {
                        Toast.makeText(this@LoginPage, "Login successful", Toast.LENGTH_SHORT)
                            .show()
                        startActivity(Intent(this@LoginPage, HomePage::class.java))
                    } else {
                        Toast.makeText(
                            this@LoginPage,
                            "Invalid username or password",
                            Toast.LENGTH_SHORT
                        ).show()
                    }

                    LoginBackButton.setOnClickListener {}
                    intent = Intent(applicationContext, MainActivity::class.java)
                    startActivity(intent)


                    ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
                        val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
                        v.setPadding(
                            systemBars.left,
                            systemBars.top,
                            systemBars.right,
                            systemBars.bottom
                        )
                        insets
                    }
                }
            }
        }
    }
}