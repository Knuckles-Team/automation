import autogen
import chromadb

termination_msg = lambda x: isinstance(x, dict) and "TERMINATE" == str(x.get("content", ""))[-9:].upper()
local_config_list = autogen.config_list_from_json(
    "OAI_CONFIG_LIST",
    filter_dict={
        "model": ["codellama-7b-instruct"],
    },
)

gpt4_config_list = autogen.config_list_from_json(
    "OAI_CONFIG_LIST",
    file_location=".",
    filter_dict={
        "model": ["gpt-4-32k", "gpt-4-32k-0314", "gpt-4-32k-0314"],
    },
)

model_config = {
    "seed": 42,  # change the seed for different trials
    "temperature": 0.7,
    "config_list": local_config_list,
    "request_timeout": 3600,
    "repeat_penalty": 1.100000
}

user_proxy = autogen.UserProxyAgent(
    name="Admin",
    system_message="A human admin. Interact with the planner to discuss the plan. "
                   "Plan execution needs to be approved by this admin. "
                   "Reply `TERMINATE` in the end when everything is done.",
    code_execution_config=False,
)
engineer = autogen.AssistantAgent(
    name="Engineer",
    llm_config=model_config,
    system_message='''Engineer. You follow an approved plan. You write python/shell code to solve tasks. 
Wrap the code in a code block that specifies the script type. The user can't modify your code. 
So do not suggest incomplete code which requires others to modify. 
Don't use a code block if it's not intended to be executed by the executor.
Don't include multiple code blocks in one response. Do not ask others to copy and paste the result. 
Check the execution result returned by the executor.
If the result indicates there is an error, fix the error and output the code again. 
Suggest the full code instead of partial code or code changes. 
If the error can't be fixed or if the task is not solved even after the code is executed successfully, analyze the problem, revisit your assumption, collect additional info you need, and think of a different approach to try.
Reply `TERMINATE` in the end when everything is done.
''',
    is_termination_msg=termination_msg,
)
scientist = autogen.AssistantAgent(
    name="Scientist",
    llm_config=model_config,
    system_message="""Scientist. You follow an approved plan. You are able to categorize papers after seeing their abstracts printed. You don't write code.""",
    is_termination_msg=termination_msg,
)
planner = autogen.AssistantAgent(
    name="Planner",
    system_message='''Planner. Suggest a plan. Revise the plan based on feedback from admin and critic, until admin approval.
The plan may involve an engineer who can write code and a scientist who doesn't write code.
Explain the plan first. Be clear which step is performed by an engineer, and which step is performed by a scientist.
Reply `TERMINATE` in the end when everything is done.
''',
    llm_config=model_config,
    is_termination_msg=termination_msg,
)
executor = autogen.UserProxyAgent(
    name="Executor",
    system_message="Executor. Execute the code written by the engineer and report the result. "
                   "Reply `TERMINATE` in the end when everything is done.",
    human_input_mode="NEVER",
    code_execution_config={"last_n_messages": 3, "work_dir": "paper"},
    is_termination_msg=termination_msg,
)
critic = autogen.AssistantAgent(
    name="Critic",
    system_message="Critic. Double check plan, claims, code from other agents and provide feedback. "
                   "Check whether the plan includes adding verifiable info such as source URL. "
                   "Reply `TERMINATE` in the end when everything is done.",
    llm_config=model_config,
    is_termination_msg=termination_msg,
)
geniusbot = autogen.agentchat.contrib.retrieve_user_proxy_agent.RetrieveAssistantAgent(
    name="Geniusbot",
    system_message="Geniusbot. You can perform any tasks in media-downloader python library. "
                   "This library allows you to download videos from the internet or download them as audio only."
                   "Reply `TERMINATE` in the end when everything is done.",
    llm_config=model_config,
    is_termination_msg=termination_msg,
)
geniusbot_qa = autogen.agentchat.contrib.retrieve_user_proxy_agent.RetrieveUserProxyAgent(
    name="Geniusbot",
    system_message="Geniusbot. You can perform any tasks in media-downloader python library. "
                   "This library allows you to download videos from the internet or download them as audio only."
                   "Reply `TERMINATE` in the end when everything is done.",
    llm_config=model_config,
    is_termination_msg=termination_msg,
    retrieve_config={
        "task": "qa",
        "docs_path": "https://raw.githubusercontent.com/Knuckles-Team/media-downloader/main/README.md"
    }
)

boss = autogen.UserProxyAgent(
    name="Boss",
    is_termination_msg=termination_msg,
    human_input_mode="TERMINATE",
    system_message="The boss who ask questions and give tasks.",
    code_execution_config=False,  # we don't want to execute code in this case.
)

boss_aid = autogen.agentchat.contrib.retrieve_user_proxy_agent.RetrieveUserProxyAgent(
    name="Boss_Assistant",
    is_termination_msg=termination_msg,
    system_message="Assistant who has extra content retrieval power for solving difficult problems.",
    human_input_mode="TERMINATE",
    max_consecutive_auto_reply=3,
    retrieve_config={
        "task": "code",
        "docs_path": "https://raw.githubusercontent.com/Knuckles-Team/media-downloader/main/README.md",
        "chunk_token_size": 1000,
        "model": local_config_list[0]["model"],
        "client": chromadb.PersistentClient(path="/tmp/chromadb"),
        "collection_name": "groupchat",
        "get_or_create": True,
    },
    code_execution_config=False,  # we don't want to execute code in this case.
)

coder = autogen.AssistantAgent(
    name="Senior_Python_Engineer",
    is_termination_msg=termination_msg,
    system_message="You are a senior python engineer. Reply `TERMINATE` in the end when everything is done.",
    llm_config=model_config,
)

pm = autogen.AssistantAgent(
    name="Product_Manager",
    is_termination_msg=termination_msg,
    system_message="You are a product manager. Reply `TERMINATE` in the end when everything is done.",
    llm_config=model_config,
)

reviewer = autogen.AssistantAgent(
    name="Code_Reviewer",
    is_termination_msg=termination_msg,
    system_message="You are a code reviewer. Reply `TERMINATE` in the end when everything is done.",
    llm_config=model_config,
)

groupchat = autogen.GroupChat(agents=[user_proxy, engineer, scientist, planner, executor, critic], messages=[], max_round=50)
manager = autogen.GroupChatManager(groupchat=groupchat, llm_config=model_config)