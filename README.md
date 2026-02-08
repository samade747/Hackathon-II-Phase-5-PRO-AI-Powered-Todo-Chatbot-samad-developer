# AI-Powered Todo Chatbot (Hackathon 5 PRO)

An advanced, microservices-based AI Todo Chatbot built with **FastAPI**, **Next.js**, **Dapr**, **Kafka**, and **Kubernetes**. Designed for high-performance task management with real-time AI assistance, voice recognition, and multilingual support.

## 🚀 Key Features

-   **🤖 AI Agentic Workflow**: Uses **MCP (Model Context Protocol)** with FastMCP for intelligent task orchestration.
-   **🗣️ Voice Recognition**: Integrated Web Speech API for hands-free task management.
-   **🌍 Multilingual Support**: Seamlessly switch between **English** and **Urdu** with automated translation and sentiment detection.
-   **⏱️ Mission Timers**: Track time spent on specific tasks with high precision.
-   **♻️ Mission Respawn**: Automated management of recurring tasks (Daily, Weekly, Monthly).
-   **💎 Premium UI/UX**: Built with **Next.js 15**, **Tailwind CSS**, and **Framer Motion** for a stunning, responsive experience.

## 🏗️ Architecture

The project follows a modern microservices architecture:

-   **Frontend**: Next.js (App Router) - Responsive UI with real-time chatbot interaction.
-   **Backend**: FastAPI - Python-based high-performance API handling agent logic and MCP tools.
-   **State Management/Dapr**: Uses **Dapr** for building-block services (Pub/Sub, State Store).
-   **Event Bus**: **Apache Kafka** (via Strimzi Operator) handles asynchronous communication.
-   **Database**: **Supabase** (PostgreSQL) for user data, tasks, and interaction history.
-   **Authentication**: **Better-Auth** with Supabase integration.

## 🛠️ Tech Stack

-   **Frontend**: React 19, Next.js 15, Tailwind CSS, Lucide Icons, Framer Motion.
-   **Backend**: Python, FastAPI, Pydantic, FastMCP, OpenAI/OpenRouter API.
-   **Infrastructure**: Kubernetes, Helm, Dapr, Kafka (Strimzi), Docker.

## 📦 Deployment Guide

### Prerequisites

-   Docker & Kubernetes (Minikube recommended for local dev).
-   Helm 3.x.
-   Supabase Account & Project.
-   AI API Keys (OpenAI, OpenRouter, or Groq).

### Automated Setup (Kubernetes)

1.  **Configure Environment**:
    Fill in the necessary secrets in `deploy/helm_charts/todo-app/values.yaml` or create a `.env` file in the root.

2.  **Initialize Infrastructure**:
    Run the Minikube setup script to install Dapr, Kafka (Strimzi), and Nginx Ingress:
    ```bash
    ./scripts/minikube-setup.sh
    ```

3.  **Deploy Application**:
    Build images and deploy via Helm:
    ```bash
    ./scripts/deploy.sh
    ```

### Local Development (Manual)

#### Backend:
```bash
cd backend
python -m venv venv
source venv/bin/activate  # atau venv\Scripts\activate pada Windows
pip install -r requirements.txt
uvicorn app.main:app --reload
```

#### Frontend:
```bash
cd frontend
npm install
npm run dev
```

## 🧩 MCP Agent Tools

The AI Agent utilizes several specialized tools managed via MCP:
-   `add_todo`: Deploy a new mission objective.
-   `list_todos`: Archive retrieval of current objectives.
-   `complete_todo`: Mark mission as accomplished with optional respawn.
-   `delete_todo`: Eliminate target objective from archives.
-   `manage_timer`: Start/Stop the mission clock.

## 📝 License

This project is part of the Hackathon II Phase 5. Built with passion by the AI-Powered Todo Team.
