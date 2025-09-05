[[001-plan]]
## 1. HTTP Endpoint
The endpoint should reflect that it's operating on a video, not a single comment. A POST request is still appropriate because it triggers a complex, multi-step action with side effects (storing many records in the DB).

- Method: POST
- URL: http://your-fastapi-app.com/api/v1/fetch-replies-by-video
## 2. Request Body

```JSON
{
  "video_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}
```

- **`video_url`** (string, required): The full URL of the YouTube video. The FastAPI app will be responsible for parsing the Video ID from this.
## 3. Success Response Body

✅ After the FastAPI app fetches **all top-level comments** for the video and then fetches **all the replies** for each of those comments, it will return a consolidated list.

The response should summarize the entire operation and include all the reply data, with a reference back to their parent comment.

```JSON
{
  "status": "success",
  "video_id": "dQw4w9WgXcQ",
  "total_replies_fetched": 352,
  "data": [
    {
      "id": "reply_id_1",
      "parent_id": "top_level_comment_A_id",
      "author_display_name": "User One",
      "text_original": "This is a reply to the first comment.",
      "like_count": 42,
      "published_at": "2025-08-26T14:30:00Z"
    },
    {
      "id": "reply_id_2",
      "parent_id": "top_level_comment_B_id",
      "author_display_name": "User Two",
      "text_original": "This is a reply to a different comment!",
      "like_count": 1,
      "published_at": "2025-08-27T10:00:00Z"
    }
  ]
}
```

- **`status`**: Confirms the overall operation succeeded.
- **`video_id`**: The ID parsed from the input URL, for confirmation.
- **`total_replies_fetched`**: The total count of all replies from all comments combined.
- **`data`**: A single flat array containing every reply object fetched.
    - **`parent_id`**: This is now **critical**. It tells the Elixir app which top-level comment each reply belongs to.

## 4. Error Response Body

❌ The error responses need to cover failures at different stages of this more complex process.

#### **Example 1: Invalid URL (400)**

The provided `video_url` is malformed or doesn't contain a valid video ID.
```JSON
{
  "status": "error",
  "error_code": "invalid_url",
  "message": "The provided URL is not a valid YouTube video URL."
}
```
#### **Example 2: Video Not Found or Comments Disabled (404)**

The video doesn't exist, is private, or has comments turned off.
```JSON
{
  "status": "error",
  "error_code": "video_not_found_or_comments_disabled",
  "message": "Could not retrieve comments. The video may not exist or has comments disabled."
}
```

#### **Example 3: Partial Failure during Fetch (502)**

A general error if the YouTube API fails partway through the process (e.g., quota is exhausted after fetching half the replies).
```JSON
{
  "status": "error",
  "error_code": "youtube_api_partial_failure",
  "message": "Failed during the multi-step fetch process. API quota may have been exceeded."
}
```