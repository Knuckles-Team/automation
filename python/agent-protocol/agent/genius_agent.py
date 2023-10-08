from agent_protocol import Agent, Step, Task


async def task_handler(task: Task) -> None:
    # TODO: Create initial step(s) for the task
    await Agent.db.create_step(task.task_id, ...)


async def step_handler(step: Step) -> Step:
    # TODO: handle next step
    if step.name == "print":
        print(step.input)
        step.is_last = True

    step.output = "Output from the agent"
    return step


if __name__ == "__main__":
    # Add the task handler and start the server
    Agent.setup_agent(task_handler, step_handler).start()
    