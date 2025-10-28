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
import com.example.harina.data.UserData
import com.example.harina.data.UserDataBase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class SignupPage : AppCompatActivity() {

    private lateinit var Db: UserDataBase
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_signup_page)

        val SignUpButton = findViewById<Button>(R.id.SignUpBtn)
        val SignBackButton = findViewById<Button>(R.id.SignBackBtn)
        val SignUsername = findViewById<EditText>(R.id.SignupUser)
        val SignPassword = findViewById<EditText>(R.id.SignPass)


        Db = UserDataBase.getDatabase(this)

        SignUpButton.setOnClickListener {
            val username = SignUsername.text.toString()
            val password = SignPassword.text.toString()

            if (username.isNotEmpty() && password.isNotEmpty()) {
                CoroutineScope(Dispatchers.IO).launch {
                    val newUser = UserData(username = username, password = password)
                    Db.userDao().insertUser(newUser)

                    runOnUiThread {
                        Toast.makeText(this@SignupPage, "Sign Up Successful", Toast.LENGTH_SHORT)
                            .show()
                        startActivity(
                            Intent(
                                this@SignupPage,
                                LoginPage::class.java
                            )
                        )
                        finish()
                    }
                }
            } else {
                Toast.makeText(this, "Please enter username and password", Toast.LENGTH_SHORT)
                    .show()
            }
        }

        SignBackButton.setOnClickListener {
            intent = Intent(this, MainActivity::class.java)
            startActivity(intent)
        }


        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }
    }
}