package com.example.harina.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query

@Dao
interface UserDao {
    @Insert
    suspend fun insertUser(user: UserData)

    @Query("SELECT * FROM User_table WHERE username = :username AND password = :password")
    suspend fun login(username: String, password: String): UserData?
}