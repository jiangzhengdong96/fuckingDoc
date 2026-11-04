import kotlinx.coroutines.*

suspend fun greeting(id: Int, waitMillis: Long): String {
    val prefix = "user-$id"
    println("A before first delay: $prefix")
    delay(waitMillis)
    val score = id + 10
    println("B after first delay: $prefix, score=$score")
    delay(waitMillis)
    val answer = "$prefix:$score"
    println("C after second delay: $answer")
    return answer
}

fun main(args: Array<String>) = runBlocking {
    val waitMillis = args.firstOrNull()?.toLong() ?: 100L
    launch { println("OTHER child ran") }
    println("CALL greeting")
    val answer = greeting(7, waitMillis)
    println("RETURN $answer")
}
