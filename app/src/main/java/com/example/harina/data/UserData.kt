package com.example.harina.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "User_table")
data class UserData(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val username: String,
    val password: String,
)